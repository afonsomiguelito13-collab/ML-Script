-- ML Script | parte3.lua
-- Loops: farm, kill, glitch, misc (Userspin45)
print("[ML] parte3 loops ✅")

local ML = getgenv().ML
if not ML then
    warn("[ML] parte1 missing")
    return
end

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
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
    if tool then pcall(function() tool:Activate() end) end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new())
    end)
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

-- FARM
task.spawn(function()
    while true do
        if ML.Flags.AutoLift or ML.Flags.AutoStrength then
            ML.equipTrain()
            ML.fireRep()
            activateTool()
        end
        if ML.Flags.FastPunch then
            ML.equipPunch()
            ML.fireRep()
            activateTool()
        end
        task.wait(0.12)
    end
end)

task.spawn(function()
    while true do
        if ML.Flags.AutoRebirth then ML.fireRebirth() end
        task.wait(0.35)
    end
end)

-- SILENT KILL recommended
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

-- SILENT KILL 2 / AURA
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

-- GLITCH ROCKS BETA
local function findRocks()
    local list = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name
            for _, rn in ipairs(ML.RockNames) do
                if string.find(string.lower(n), string.lower(rn), 1, true) then
                    table.insert(list, v)
                    break
                end
            end
        end
    end
    return list
end

task.spawn(function()
    local rocks, lastScan = {}, 0
    while true do
        if ML.Flags.GlitchRocks then
            if tick() - lastScan > 8 or #rocks == 0 then
                rocks = findRocks()
                lastScan = tick()
            end
            ML.equipPunch()
            local hrp = ML.getHRP()
            for _, rock in ipairs(rocks) do
                if rock and rock.Parent then
                    pcall(function()
                        if firetouchinterest and hrp then
                            firetouchinterest(hrp, rock, 0)
                            firetouchinterest(hrp, rock, 1)
                        end
                    end)
                    activateTool()
                    ML.fireRep()
                end
            end
            local spd = tonumber(ML.Settings.GlitchSpeed) or 2
            task.wait(math.max(0.05, 0.2 / spd))
        else
            task.wait(0.4)
        end
    end
end)

-- ANTI AFK
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

-- ANTI DIE
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

print("[ML] parte3 loops running ✅ SilentKill / Glitch / Farm")
print("[ML] Userspin45 | " .. (ML.Version or "?"))
