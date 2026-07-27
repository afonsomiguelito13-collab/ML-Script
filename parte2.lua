-- ML Script | parte2.lua
-- Fluent UI + tabs + dragon button (Userspin45)
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
    print("[ML] UI lib fail - features still in ML.Flags via getgenv")
    return
end

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
end)

local Window = Fluent:CreateWindow({
    Title = "ML Script",
    SubTitle = "Userspin45 | MEGA",
    TabWidth = 130,
    Size = UDim2.fromOffset(520, 420),
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
Tabs.Main:AddParagraph({ Title = "Farm", Content = "Lift/Weight = Weight tool only | Strength = train tools | Punch = Punch only" })
addToggle(Tabs.Main, "Auto Lift (Weight)", "AutoLift", false)
addToggle(Tabs.Main, "Auto Weight", "AutoWeight", false)
addToggle(Tabs.Main, "Fast Punch (Punch only)", "FastPunch", false)
addToggle(Tabs.Main, "Auto Strength (train tools)", "AutoStrength", false)
addToggle(Tabs.Main, "Auto Rebirth", "AutoRebirth", false)
addToggle(Tabs.Main, "Auto Chests", "AutoChests", false)
addToggle(Tabs.Main, "Auto Brawl", "AutoBrawl", false)

-- KILL
Tabs.Kill:AddParagraph({ Title = "Combat", Content = "Silent Kill recommended | SK2 = aggressive | Punch only" })
addToggle(Tabs.Kill, "Silent Kill [Recommended]", "SilentKill", false)
addToggle(Tabs.Kill, "Silent Kill 2 (Aura hate mode)", "SilentKill2", false)
addToggle(Tabs.Kill, "Kill Aura", "KillAura", false)
Tabs.Kill:AddSlider("AuraSize", {
    Title = "Aura / Hitbox Size",
    Description = "Silent Kill 2 / Kill Aura range",
    Default = 15, Min = 5, Max = 50, Rounding = 0,
    Callback = function(v) ML.Settings.AuraSize = v end
})

-- GLITCH
Tabs.Glitch:AddParagraph({
    Title = "Rocks",
    Content = "Auto Hit Rock from far (firetouchinterest). No need to stand on rock."
})
addToggle(Tabs.Glitch, "Auto Rock [BETA]", "GlitchRocks", false)
Tabs.Glitch:AddSlider("GlitchSpeed", {
    Title = "Rock Hit Speed",
    Description = "Loop speed (1-5)",
    Default = 2, Min = 1, Max = 5, Rounding = 1,
    Callback = function(v) ML.Settings.GlitchSpeed = v end
})
Tabs.Glitch:AddParagraph({
    Title = "Found rocks",
    Content = "Press button below after enabling Auto Rock (table updates every scan)."
})
Tabs.Glitch:AddButton({
    Title = "Show found rocks table",
    Callback = function()
        local names = ML.FoundRockNames or {}
        local n = #names
        if n == 0 then
            print("[ML] Found rocks: 0 (enable Auto Rock first)")
            pcall(function()
                Fluent:Notify({ Title = "Found rocks", Content = "0 rocks — enable Auto Rock", Duration = 4 })
            end)
            return
        end
        local unique = {}
        local order = {}
        for _, name in ipairs(names) do
            if not unique[name] then
                unique[name] = 0
                table.insert(order, name)
            end
            unique[name] = unique[name] + 1
        end
        local lines = { "Found: " .. tostring(n) .. " parts" }
        for _, name in ipairs(order) do
            table.insert(lines, name .. " x" .. tostring(unique[name]))
        end
        local text = table.concat(lines, "\n")
        print("[ML] === Found rocks table ===\n" .. text)
        pcall(function()
            Fluent:Notify({ Title = "Found rocks (" .. n .. ")", Content = table.concat(order, ", "), Duration = 6 })
        end)
    end
})
Tabs.Glitch:AddParagraph({
    Title = "How it works",
    Content = "equipPunch → scan rocks → firetouchinterest (far) → Activate → rep\nHub-style Auto Rock (KOD / Enchanted / Speed)."
})
Tabs.Glitch:AddParagraph({
    Title = "Pet XP note",
    Content = "Not a dupe. Unique @ Muscle King needs exact rebirth (580 / 630 / 980...). Auto Rebirth OFF. Lvl 1 · 0 XP."
})
Tabs.Glitch:AddParagraph({
    Title = "Status",
    Content = "BETA · may break after updates · no ClickButton1"
})

-- MISC
Tabs.Misc:AddParagraph({ Title = "Quality of life", Content = "Anti AFK / Die / Reconnect / Speed" })
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
Tabs.Misc:AddParagraph({
    Title = "Auto Reconnection",
    Content = "On kick / disconnect / error prompt → Teleport back to same place. Leave ON for AFK farm."
})
Tabs.Misc:AddParagraph({
    Title = "Warning",
    Content = "AUTO EXECUTE DOES NOT WORK WELL on all Delta builds"
})

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
Tabs.TPs:AddButton({ Title = "Muscle King Gym (approx)", Callback = function() tpTo(CFrame.new(-2692, 246, 119)) end })

-- ADVANCED
Tabs.Advanced:AddParagraph({ Title = "Advanced Section", Content = "SOON" })
Tabs.Advanced:AddParagraph({
    Title = "Planned",
    Content = "More methods, safer locks, config save, pet helpers.\n\nSOON - Userspin45"
})

-- CREDITS
Tabs.Credits:AddParagraph({
    Title = "ML Script",
    Content = "Creator: Userspin45\nMuscle Legends MEGA FINAL\nSilent Kill - Auto Rock - Farm"
})
Tabs.Credits:AddParagraph({
    Title = "Warnings",
    Content = "- AUTO EXECUTE WEAK\n- AUTO ROCK BETA\n- Punch only / Weight only tools\n- Auto Rebirth OFF for pet glitch (630)"
})
Tabs.Credits:AddParagraph({
    Title = "Links",
    Content = "GitHub: afonsomiguelito13-collab/ML-Script\nScriptBlox: search ML Script"
})

Window:SelectTab(1)

-- ===== TOGGLE BUTTON (full icon) =====
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
    string.format("rbxthumb://type=Asset&id=%d&w=420&h=420", ICON_ID),
}

local btn = Instance.new("ImageButton")
btn.Name = "ToggleBtn"
btn.Size = UDim2.fromOffset(58, 58)
btn.Position = UDim2.new(0, 14, 0.45, 0)
btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
btn.BackgroundTransparency = 0
btn.BorderSizePixel = 0
btn.Image = ICON_URLS[1]
btn.ImageColor3 = Color3.fromRGB(255, 255, 255)
btn.ScaleType = Enum.ScaleType.Fit
btn.AutoButtonColor = true
btn.Parent = toggleGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = btn

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(40, 40, 45)
stroke.Thickness = 1.5
stroke.Parent = btn

-- big icon (almost full button)
local icon = Instance.new("ImageLabel")
icon.Name = "Icon"
icon.BackgroundTransparency = 1
icon.Size = UDim2.fromScale(0.92, 0.92)
icon.Position = UDim2.fromScale(0.04, 0.04)
icon.Image = ICON_URLS[1]
icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
icon.ScaleType = Enum.ScaleType.Fit
icon.ZIndex = 2
icon.Parent = btn

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 2)
pad.PaddingBottom = UDim.new(0, 2)
pad.PaddingLeft = UDim.new(0, 2)
pad.PaddingRight = UDim.new(0, 2)
pad.Parent = btn

task.spawn(function()
    for _, url in ipairs(ICON_URLS) do
        pcall(function()
            btn.Image = url
            icon.Image = url
        end)
        task.wait(0.35)
    end
end)

-- rock count badge under button
local rockBadge = Instance.new("TextLabel")
rockBadge.Name = "RockBadge"
rockBadge.Size = UDim2.fromOffset(58, 16)
rockBadge.Position = UDim2.new(0, 14, 0.45, 60)
rockBadge.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
rockBadge.BackgroundTransparency = 0.2
rockBadge.TextColor3 = Color3.fromRGB(180, 255, 180)
rockBadge.Font = Enum.Font.GothamBold
rockBadge.TextSize = 10
rockBadge.Text = "R:0"
rockBadge.Parent = toggleGui
Instance.new("UICorner", rockBadge).CornerRadius = UDim.new(0, 6)

task.spawn(function()
    while rockBadge and rockBadge.Parent do
        local n = 0
        if ML.FoundRocks then n = #ML.FoundRocks end
        rockBadge.Text = "R:" .. tostring(n)
        rockBadge.Visible = (ML.Flags.GlitchRocks == true) or (n > 0)
        task.wait(1)
    end
end)

local dragging, dragStart, startPos, dragBadge
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = btn.Position
        dragBadge = rockBadge.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        rockBadge.Position = UDim2.new(
            dragBadge.X.Scale, dragBadge.X.Offset + delta.X,
            dragBadge.Y.Scale, dragBadge.Y.Offset + delta.Y
        )
    end
end)

local uiOpen = true
local function setFluentVisible(vis)
    pcall(function()
        if Window.Root then Window.Root.Visible = vis end
    end)
    pcall(function()
        if Window.UI then Window.UI.Visible = vis end
    end)
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui ~= toggleGui then
            local n = string.lower(gui.Name)
            if n:find("fluent") or n:find("window") or n:find("ml script") then
                gui.Visible = vis
            end
        end
    end
end

btn.MouseButton1Click:Connect(function()
    uiOpen = not uiOpen
    setFluentVisible(uiOpen)
    stroke.Color = uiOpen and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(50, 160, 80)
    icon.ImageTransparency = uiOpen and 0 or 0.1
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
end)

print("[ML] parte2 ready | icon full | AutoReconnect | found rocks table")
