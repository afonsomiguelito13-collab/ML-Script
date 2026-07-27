-- ML Script | parte2.lua
-- Fluent UI + tabs + dragon button + Rock select (Userspin45)
print("[ML] parte2 UI OK")

local ML = getgenv().ML
if not ML then
    warn("[ML] parte1 not loaded")
    return
end

local Fluent
local okFluent, errFluent = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)
if not okFluent or not Fluent then
    okFluent, errFluent = pcall(function()
        Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/init.lua"))()
    end)
end
if not Fluent then
    warn("[ML] Fluent failed to load:", errFluent)
    return
end

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
end)

local Window = Fluent:CreateWindow({
    Title = "ML Script",
    SubTitle = "Userspin45 | MEGA",
    TabWidth = 130,
    Size = UDim2.fromOffset(520, 440),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

getgenv().ML_Window = Window
ML.Window = Window

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "dumbbell" }),
    Kill = Window:AddTab({ Title = "Kill", Icon = "swords" }),
    Glitch = Window:AddTab({ Title = "Glitch", Icon = "sparkles" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    TPs = Window:AddTab({ Title = "TPs", Icon = "map-pin" }),
    Advanced = Window:AddTab({ Title = "Advanced", Icon = "cpu" }),
    Credits = Window:AddTab({ Title = "Credits", Icon = "info" }),
}

local function addToggle(tab, name, flagKey, default, cb)
    return tab:AddToggle(flagKey, {
        Title = name,
        Default = default or false,
        Callback = function(state)
            ML.Flags[flagKey] = state
            if cb then pcall(cb, state) end
        end
    })
end

-- MAIN
Tabs.Main:AddParagraph({
    Title = "Farm Tools",
    Content = "Weight = Weight only | Strength = Situps/Pushups/Handstands | Punch = Punch only"
})
addToggle(Tabs.Main, "Auto Lift (Weight)", "AutoLift", false)
addToggle(Tabs.Main, "Auto Weight", "AutoWeight", false)
addToggle(Tabs.Main, "Auto Strength (train tools)", "AutoStrength", false)
Tabs.Main:AddParagraph({
    Title = "Fast Punch",
    Content = "Punch only · Animation 5x (visual)\nPeople see the speed · Durability rate stays normal"
})
addToggle(Tabs.Main, "Fast Punch [5x Anim]", "FastPunch", false)
Tabs.Main:AddParagraph({ Title = "Other", Content = "Rebirth / Chests / Brawl" })
addToggle(Tabs.Main, "Auto Rebirth", "AutoRebirth", false)
addToggle(Tabs.Main, "Auto Chests", "AutoChests", false)
addToggle(Tabs.Main, "Auto Brawl", "AutoBrawl", false)

-- KILL
Tabs.Kill:AddParagraph({
    Title = "Combat",
    Content = "All kill modes use Punch only.\nSilent Kill = recommended | SK2 = aggressive aura"
})
addToggle(Tabs.Kill, "Silent Kill [Recommended]", "SilentKill", false)
addToggle(Tabs.Kill, "Silent Kill 2 (Aura hate)", "SilentKill2", false)
addToggle(Tabs.Kill, "Kill Aura", "KillAura", false)
Tabs.Kill:AddSlider("AuraSize", {
    Title = "Aura / Hitbox Size",
    Description = "Silent Kill 2 / Kill Aura range",
    Default = 15, Min = 5, Max = 50, Rounding = 0,
    Callback = function(v) ML.Settings.AuraSize = v end
})

-- GLITCH + ROCK SELECT
Tabs.Glitch:AddParagraph({
    Title = "Auto Rock",
    Content = "Hub method: firetouchinterest + Punch. Works from far.\nPick the rock first so pet glitch hits the RIGHT rock."
})

local ROCK_OPTIONS = {
    "All", "Muscle King", "Legend", "Tiny", "Punching",
    "Golden", "Frost", "Eternal", "Mythical", "Jungle", "Green",
}
ML.Settings.SelectedRock = ML.Settings.SelectedRock or "All"

pcall(function()
    Tabs.Glitch:AddDropdown("SelectedRock", {
        Title = "Choose Rock (pet glitch)",
        Description = "Pick the rock to hit — avoids wrong rock / pet not glitching",
        Values = ROCK_OPTIONS,
        Default = ML.Settings.SelectedRock,
        Multi = false,
        Callback = function(value)
            ML.Settings.SelectedRock = value
            print("[ML] Selected rock:", value)
            pcall(function()
                Fluent:Notify({ Title = "Rock selected", Content = tostring(value), Duration = 3 })
            end)
        end
    })
end)

Tabs.Glitch:AddParagraph({ Title = "Quick select", Content = "If dropdown missing, use buttons." })

local function setRock(name)
    ML.Settings.SelectedRock = name
    print("[ML] Selected rock:", name)
end
Tabs.Glitch:AddButton({ Title = "Rock: All", Callback = function() setRock("All") end })
Tabs.Glitch:AddButton({ Title = "Rock: Muscle King (best pet)", Callback = function() setRock("Muscle King") end })
Tabs.Glitch:AddButton({ Title = "Rock: Legend", Callback = function() setRock("Legend") end })
Tabs.Glitch:AddButton({ Title = "Rock: Tiny", Callback = function() setRock("Tiny") end })
Tabs.Glitch:AddButton({ Title = "Rock: Punching / Golden", Callback = function() setRock("Punching") end })

addToggle(Tabs.Glitch, "Auto Rock [BETA]", "GlitchRocks", false)
Tabs.Glitch:AddSlider("GlitchSpeed", {
    Title = "Rock Hit Speed", Description = "Loop speed (1-5)",
    Default = 2, Min = 1, Max = 5, Rounding = 1,
    Callback = function(v) ML.Settings.GlitchSpeed = v end
})

Tabs.Glitch:AddButton({
    Title = "Show found rocks table",
    Callback = function()
        local names = ML.FoundRockNames or {}
        local n = #names
        local sel = ML.Settings.SelectedRock or "All"
        if n == 0 then
            print("[ML] Found rocks: 0")
            pcall(function() Fluent:Notify({ Title = "Found rocks", Content = "0 — enable Auto Rock", Duration = 4 }) end)
            return
        end
        local unique, order = {}, {}
        for _, name in ipairs(names) do
            if not unique[name] then unique[name] = 0; table.insert(order, name) end
            unique[name] = unique[name] + 1
        end
        print("[ML] Selected:", sel)
        for _, name in ipairs(order) do print("  " .. name .. " x" .. unique[name]) end
        pcall(function()
            Fluent:Notify({ Title = "Rocks (" .. n .. ") | Sel: " .. sel, Content = table.concat(order, ", "), Duration = 6 })
        end)
    end
})

Tabs.Glitch:AddParagraph({
    Title = "How it works",
    Content = "1) Choose rock (Muscle King / Legend for pet)\n2) Enable Auto Rock\n3) Punch + firetouchinterest + rep\nWorks from far."
})
Tabs.Glitch:AddParagraph({
    Title = "Pet XP glitch",
    Content = "NOT a dupe. Pet LVL 1 · 0 XP. Exact rebirth (580/630/980...).\nAuto Rebirth OFF. Wrong rock = no glitch."
})
Tabs.Glitch:AddParagraph({ Title = "Status", Content = "BETA · rock filter ON · no ClickButton1" })

-- MISC
Tabs.Misc:AddParagraph({ Title = "Quality of Life", Content = "Anti AFK · Anti Die · Auto Reconnect · Speed · Counter" })
addToggle(Tabs.Misc, "Anti AFK", "AntiAFK", false)
addToggle(Tabs.Misc, "Anti Die", "AntiDie", false)
addToggle(Tabs.Misc, "Auto Reconnection", "AutoReconnect", false)
addToggle(Tabs.Misc, "Kill Counter UI", "KillCounter", false)
addToggle(Tabs.Misc, "Auto Execute (Delta) - weak", "AutoExecute", false)
Tabs.Misc:AddSlider("WalkSpeed", {
    Title = "WalkSpeed", Default = 16, Min = 16, Max = 120, Rounding = 0,
    Callback = function(v)
        ML.Settings.WalkSpeed = v
        local h = ML.getHum()
        if h then pcall(function() h.WalkSpeed = v end) end
    end
})
Tabs.Misc:AddParagraph({ Title = "Auto Reconnection", Content = "On kick/error → Teleport same place." })
Tabs.Misc:AddParagraph({ Title = "Warning", Content = "AUTO EXECUTE DOES NOT WORK WELL on all Delta builds" })

-- TPs
local function tpTo(cf)
    local hrp = ML.getHRP()
    if hrp then hrp.CFrame = cf end
end
Tabs.TPs:AddButton({ Title = "Mythical Gym", Callback = function() tpTo(CFrame.new(2386.89, 139.61, 1094.26)) end })
Tabs.TPs:AddButton({ Title = "Frost Gym", Callback = function() tpTo(CFrame.new(-2752.57, 125.82, -386.74)) end })
Tabs.TPs:AddButton({ Title = "Eternal Gym", Callback = function() tpTo(CFrame.new(-6917.79, 182.35, -1336.64)) end })
Tabs.TPs:AddButton({ Title = "Tiny Island", Callback = function() tpTo(CFrame.new(-4.25, 220.99, 1963.60)) end })
Tabs.TPs:AddButton({ Title = "Brawl Aura 1", Callback = function() tpTo(CFrame.new(985.91, 163.80, -7037.81)) end })
Tabs.TPs:AddButton({ Title = "Brawl Aura 2", Callback = function() tpTo(CFrame.new(4466.75, 334.97, -8425.75)) end })
Tabs.TPs:AddButton({ Title = "Brawl Aura 3", Callback = function() tpTo(CFrame.new(-1901.88, 251.90, -5899.65)) end })
Tabs.TPs:AddButton({ Title = "Muscle King Gym", Callback = function() tpTo(CFrame.new(-2692, 246, 119)) end })

Tabs.Advanced:AddParagraph({ Title = "Advanced Section", Content = "SOON" })
Tabs.Advanced:AddParagraph({ Title = "Planned", Content = "Safer locks, config save, pet helpers.\n\nSOON - Userspin45" })

Tabs.Credits:AddParagraph({ Title = "ML Script", Content = "Creator: Userspin45\nMuscle Legends MEGA\nSilent Kill · Auto Rock · Farm" })
Tabs.Credits:AddParagraph({ Title = "Warnings", Content = "- AUTO EXECUTE WEAK\n- Choose rock before pet glitch\n- Auto Rebirth OFF for glitch (630)" })
Tabs.Credits:AddParagraph({ Title = "Links", Content = "GitHub: afonsomiguelito13-collab/ML-Script" })

Window:SelectTab(1)

-- Toggle button + badge
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ML_Script_Toggle"
toggleGui.ResetOnSpawn = false
toggleGui.IgnoreGuiInset = true
toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
toggleGui.DisplayOrder = 999
toggleGui.Parent = playerGui

local ICON_ID = 7999214852
local ICON_URLS = {
    "rbxassetid://" .. tostring(ICON_ID),
    "http://www.roblox.com/asset/?id=" .. tostring(ICON_ID),
    string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", ICON_ID),
}

local btn = Instance.new("ImageButton")
btn.Name = "ToggleBtn"
btn.Size = UDim2.fromOffset(58, 58)
btn.Position = UDim2.new(0, 14, 0.45, 0)
btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
btn.Image = ICON_URLS[1]
btn.ScaleType = Enum.ScaleType.Fit
btn.AutoButtonColor = true
btn.Parent = toggleGui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(40, 40, 45)
stroke.Thickness = 1.5
stroke.Parent = btn

local icon = Instance.new("ImageLabel")
icon.BackgroundTransparency = 1
icon.Size = UDim2.fromScale(0.92, 0.92)
icon.Position = UDim2.fromScale(0.04, 0.04)
icon.Image = ICON_URLS[1]
icon.ScaleType = Enum.ScaleType.Fit
icon.ZIndex = 2
icon.Parent = btn

task.spawn(function()
    for _, url in ipairs(ICON_URLS) do
        pcall(function() btn.Image = url; icon.Image = url end)
        task.wait(0.35)
    end
end)

local rockBadge = Instance.new("TextLabel")
rockBadge.Size = UDim2.fromOffset(58, 28)
rockBadge.Position = UDim2.new(0, 14, 0.45, 60)
rockBadge.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
rockBadge.BackgroundTransparency = 0.2
rockBadge.TextColor3 = Color3.fromRGB(180, 255, 180)
rockBadge.Font = Enum.Font.GothamBold
rockBadge.TextSize = 9
rockBadge.Text = "R:0\nAll"
rockBadge.TextWrapped = true
rockBadge.Parent = toggleGui
Instance.new("UICorner", rockBadge).CornerRadius = UDim.new(0, 6)

task.spawn(function()
    while rockBadge.Parent do
        local n = ML.FoundRocks and #ML.FoundRocks or 0
        local sel = tostring(ML.Settings.SelectedRock or "All")
        if #sel > 8 then sel = string.sub(sel, 1, 7) .. "." end
        rockBadge.Text = "R:" .. n .. "\n" .. sel
        task.wait(1)
    end
end)

local dragging, dragStart, startPos, dragBadge
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = btn.Position
        dragBadge = rockBadge.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        rockBadge.Position = UDim2.new(dragBadge.X.Scale, dragBadge.X.Offset + delta.X, dragBadge.Y.Scale, dragBadge.Y.Offset + delta.Y)
    end
end)

local uiOpen = true
local function setFluentVisible(vis)
    pcall(function() if Window.Root then Window.Root.Visible = vis end end)
    pcall(function() if Window.UI then Window.UI.Visible = vis end end)
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui ~= toggleGui then
            local n = string.lower(gui.Name)
            if n:find("fluent") or n:find("window") or n:find("ml script") then gui.Visible = vis end
        end
    end
end
btn.MouseButton1Click:Connect(function()
    uiOpen = not uiOpen
    setFluentVisible(uiOpen)
    stroke.Color = uiOpen and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(50, 160, 80)
end)

print("[ML] parte2 ready | rock select | Fast Punch 5x")
