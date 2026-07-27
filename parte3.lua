-- ML Script | parte3.lua
-- Farm / Kill / Auto Rock (selected rock) / Reconnect (Userspin45)
print("[ML] parte3 loops OK")

local ML = getgenv().ML
if not ML then
    warn("[ML] parte1 missing")
    return
end

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local LP = ML.LP

local kills = 0
local counterGui

local function ensureCounter()
    if counterGui and counterGui.Parent then return end
    local pg = LP:WaitForChild("PlayerGui")
    counterGui = Instance.new("ScreenGui")
    counterGui.Name = "ML_KillCounter"
    counterGui.ResetOnSpawn = false
    counterGui.IgnoreGuiInset = true
    counterGui.Parent = pg
    local lab = Instance.new("TextLabel")
    lab.Name = "Label"
    lab.Size = UDim2.fromOffset(160, 36)
    lab.Position = UDim2.new(0.5, -80, 0, 40)
    lab.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    lab.BackgroundTransparency = 0.25
    lab.TextColor3 = Color3.fromRGB(255, 220, 220)
    lab.Font = Enum.Font.GothamBold
    lab.TextSize = 16
    lab.Text = "Kills: 0"
    lab.Parent = counterGui
    Instance.new("UICorner", lab).CornerRadius = UDim.new(0, 8)
end

local function setCounterVisible(on)
    if on then
        ensureCounter()
        counterGui.Enabled = true
        local lab = counterGui:FindFirstChild("Label")
        if lab then lab.Text = "Kills: " .. kills end
    elseif counterGui then
        counterGui.Enabled = false
    end
end

local function addKill()
    kills += 1
    if counterGui and counterGui.Enabled then
        local lab = counterGui:FindFirstChild("Label")
        if lab then lab.Text = "Kills: " .. kills end
    end
end

local function activateTool()
    local char = LP.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
    end
end

local function nearestPlayer(maxDist)
    local hrp = ML.getHRP()
    if not hrp then return nil end
    local best, bestD
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local ohrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if ohrp and hum and hum.Health > 0 then
                local d = (ohrp.Position - hrp.Position).Magnitude
                if d <= (maxDist or 1e9) and (not bestD or d < bestD) then
                    best, bestD = plr, d
                end
            end
        end
    end
    return best, bestD
end

-- Fast Punch anim 5x (visual only)
local function speedPunchAnims(mult)
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function()
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            local n = string.lower(track.Name or "")
            if n:find("punch") or n:find("combat") or n:find("attack") or n:find("hit") or n:find("swing") then
                track:AdjustSpeed(mult)
            end
        end
    end)
end

-- Weight / Strength
task.spawn(function()
    while true do
        if ML.Flags.AutoLift or ML.Flags.AutoWeight then
            ML.equipWeight()
            ML.fireRep()
            activateTool()
        end
        if ML.Flags.AutoStrength then
            ML.equipTrain()
            ML.fireRep()
            activateTool()
        end
        task.wait(0.12)
    end
end)

-- Fast Punch 5x anim
task.spawn(function()
    while true do
        if ML.Flags.FastPunch then
            ML.equipPunch()
            ML.fireRep()
            activateTool()
            speedPunchAnims(5)
            task.wait(0.04)
        else
            task.wait(0.25)
        end
    end
end)

task.spawn(function()
    while true do
        if ML.Flags.AutoRebirth then
            ML.fireRebirth()
        end
        task.wait(0.35)
    end
end)

-- Silent Kill
task.spawn(function()
    while true do
        if ML.Flags.SilentKill then
            ML.equipPunch()
            local target = nearestPlayer(200)
            if target and target.Character then
                local thrp = target.Character:FindFirstChild("HumanoidRootPart")
                local hrp = ML.getHRP()
                if thrp and hrp then
                    hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 3)
                    activateTool()
                    ML.fireRep()
                    local hum = target.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health <= 0 then addKill() end
                end
            end
            task.wait(0.08)
        else
            task.wait(0.2)
        end
    end
end)

-- Silent Kill 2 / Aura
task.spawn(function()
    while true do
        local auraOn = ML.Flags.SilentKill2 or ML.Flags.KillAura
        if auraOn then
            ML.equipPunch()
            local size = ML.Settings.AuraSize or 15
            local hrp = ML.getHRP()
            if hrp then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character then
                        local ohrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if ohrp and hum and hum.Health > 0 then
                            local d = (ohrp.Position - hrp.Position).Magnitude
                            if d <= size then
                                if ML.Flags.SilentKill2 then
                                    hrp.CFrame = ohrp.CFrame * CFrame.new(0, 0, 2.5)
                                end
                                local char = LP.Character
                                if char and firetouchinterest then
                                    local lh = char:FindFirstChild("LeftHand")
                                    local rh = char:FindFirstChild("RightHand")
                                    pcall(function()
                                        if lh then firetouchinterest(ohrp, lh, 0); firetouchinterest(ohrp, lh, 1) end
                                        if rh then firetouchinterest(ohrp, rh, 0); firetouchinterest(ohrp, rh, 1) end
                                    end)
                                end
                                activateTool()
                                ML.fireRep()
                                if hum.Health <= 0 then addKill() end
                            end
                        end
                    end
                end
            end
            task.wait(0.06)
        else
            task.wait(0.2)
        end
    end
end)

-- ============================================================
-- AUTO ROCK — filter by SelectedRock (pet glitch safe)
-- ============================================================

local ROCK_FILTER = {
    ["All"] = nil,
    ["Muscle King"] = { "muscle king", "king gym", "musle king" },
    ["Legend"] = { "legend", "legends", "rock of legends" },
    ["Tiny"] = { "tiny" },
    ["Punching"] = { "punching", "punch rock" },
    ["Golden"] = { "golden", "gold rock" },
    ["Frost"] = { "frost", "frozen" },
    ["Eternal"] = { "eternal" },
    ["Mythical"] = { "mythical", "mythic" },
    ["Jungle"] = { "jungle", "ancient" },
    ["Green"] = { "green" },
}

local function rockMatchesSelection(rock, label)
    local sel = ML.Settings.SelectedRock or "All"
    if sel == "All" or not ROCK_FILTER[sel] then return true end
    local keys = ROCK_FILTER[sel]
    local hay = string.lower((label or "") .. " " .. (rock and rock.Name or "") .. " " .. (rock and rock.Parent and rock.Parent.Name or ""))
    for _, k in ipairs(keys) do
        if string.find(hay, k, 1, true) then return true end
    end
    return false
end

local function getHands()
    local char = LP.Character
    if not char then return nil, nil end
    return char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm"),
           char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
end

local function touchRockHub(rock)
    if not rock or not rock.Parent then return end
    local lh, rh = getHands()
    local hrp = ML.getHRP()
    if not firetouchinterest then return end
    pcall(function()
        if rh then firetouchinterest(rock, rh, 0); firetouchinterest(rock, rh, 1) end
        if lh then firetouchinterest(rock, lh, 0); firetouchinterest(rock, lh, 1) end
        if rh then firetouchinterest(rh, rock, 0); firetouchinterest(rh, rock, 1) end
        if lh then firetouchinterest(lh, rock, 0); firetouchinterest(lh, rock, 1) end
        if hrp then
            firetouchinterest(hrp, rock, 0); firetouchinterest(hrp, rock, 1)
            firetouchinterest(rock, hrp, 0); firetouchinterest(rock, hrp, 1)
        end
    end)
end

local function findRocksMachines()
    local list, names = {}, {}
    local folder = Workspace:FindFirstChild("machinesFolder")
    if not folder then return list, names end
    for _, v in ipairs(folder:GetDescendants()) do
        if v.Name == "neededDurability" and (v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("DoubleConstrainedValue")) then
            local parent = v.Parent
            if parent then
                local rock = parent:FindFirstChild("Rock") or parent:FindFirstChildWhichIsA("BasePart")
                if rock and rock:IsA("BasePart") then
                    local label = parent.Name
                    if v.Value then label = label .. " [dura " .. tostring(v.Value) .. "]" end
                    if rockMatchesSelection(rock, label) then
                        table.insert(list, rock)
                        table.insert(names, label)
                    end
                end
            end
        end
    end
    return list, names
end

local function findRocksByName()
    local list, names, seen = {}, {}, {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not seen[v] then
            local n = string.lower(v.Name)
            local matchKeyword = false
            for _, rn in ipairs(ML.RockNames or {}) do
                if string.find(n, string.lower(rn), 1, true) then
                    matchKeyword = true
                    break
                end
            end
            if matchKeyword and rockMatchesSelection(v, v.Name) then
                seen[v] = true
                table.insert(list, v)
                table.insert(names, v.Name)
            end
        end
    end
    return list, names
end

local function findRocks()
    local list, names = findRocksMachines()
    if #list == 0 then
        list, names = findRocksByName()
    end
    ML.FoundRocks = list
    ML.FoundRockNames = names
    return list
end

task.spawn(function()
    local rocks, lastScan = {}, 0
    while true do
        if ML.Flags.GlitchRocks then
            if tick() - lastScan > 5 or #rocks == 0 then
                rocks = findRocks()
                lastScan = tick()
                local sel = ML.Settings.SelectedRock or "All"
                print("[ML] Auto Rock | sel=" .. sel .. " | found=" .. tostring(#rocks))
                if #ML.FoundRockNames > 0 then
                    local show = table.concat(ML.FoundRockNames, " | ")
                    if #show > 160 then show = string.sub(show, 1, 160) .. "..." end
                    print("[ML] Rocks: " .. show)
                elseif sel ~= "All" then
                    print("[ML] No rock matched selection — try All or another rock")
                end
            end

            ML.equipPunch()
            for _, rock in ipairs(rocks) do
                if rock and rock.Parent then
                    touchRockHub(rock)
                    activateTool()
                    ML.fireRep()
                end
            end

            local spd = tonumber(ML.Settings.GlitchSpeed) or 2
            task.wait(math.max(0.03, 0.15 / spd))
        else
            task.wait(0.4)
        end
    end
end)

-- Anti AFK
task.spawn(function()
    while true do
        if ML.Flags.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
        task.wait(30)
    end
end)
LP.Idled:Connect(function()
    if ML.Flags.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- Anti Die
task.spawn(function()
    while true do
        if ML.Flags.AntiDie then
            local hum = ML.getHum()
            if hum and hum.Health < hum.MaxHealth * 0.2 then
                pcall(function() hum.Health = hum.MaxHealth end)
            end
        end
        task.wait(0.5)
    end
end)

-- Auto Reconnect
local reconnecting = false
local function tryReconnect(reason)
    if not ML.Flags.AutoReconnect then return end
    if reconnecting then return end
    reconnecting = true
    print("[ML] Auto Reconnect:", reason or "kick/error")
    task.spawn(function()
        task.wait(1.5)
        pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
        task.wait(8)
        reconnecting = false
    end)
end

pcall(function()
    GuiService.ErrorMessageChanged:Connect(function(msg)
        if msg and #tostring(msg) > 0 then tryReconnect(tostring(msg)) end
    end)
end)

task.spawn(function()
    while true do
        if ML.Flags.AutoReconnect then
            pcall(function()
                local pg = game:GetService("CoreGui")
                local prompt = pg:FindFirstChild("RobloxPromptGui")
                if prompt then
                    local overlay = prompt:FindFirstChild("promptOverlay")
                    if overlay then
                        for _, d in ipairs(overlay:GetDescendants()) do
                            if d:IsA("TextLabel") then
                                local t = string.lower(d.Text or "")
                                if t:find("reconnect") or t:find("disconnected") or t:find("kick") or t:find("error") then
                                    tryReconnect(d.Text)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(3)
    end
end)

local function onChar(char)
    task.wait(0.3)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and ML.Settings.WalkSpeed then
        pcall(function() hum.WalkSpeed = ML.Settings.WalkSpeed end)
    end
end
if LP.Character then onChar(LP.Character) end
LP.CharacterAdded:Connect(onChar)

task.spawn(function()
    while true do
        setCounterVisible(ML.Flags.KillCounter == true)
        task.wait(0.5)
    end
end)

print("[ML] parte3 OK | SelectedRock filter | FastPunch 5x | hub Auto Rock")
print("[ML] Userspin45 | " .. (ML.Version or "?"))
