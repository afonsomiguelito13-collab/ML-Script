-- ML Script | parte2.lua
-- Fluent UI + tabs + Open/Close button (Userspin45)
print("[ML] parte2 UI ✅")

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
    print("[ML] UI lib fail — features still in ML.Flags via getgenv")
    return
end

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
end)

local Window = Fluent:CreateWindow({
    Title = "ML Script",
    SubTitle = "Userspin45 | MEGA",
    TabWidth = 130,
    Size = UDim2.fromOffset(520, 380),
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
Tabs.Main:AddParagraph({ Title = "Farm", Content = "Auto Lift / Punch / Strength / Rebirth" })
addToggle(Tabs.Main, "Auto Lift", "AutoLift", false)
addToggle(Tabs.Main, "Fast Punch (Punch only)", "FastPunch", false)
addToggle(Tabs.Main, "Auto Strength (train tools)", "AutoStrength", false)
addToggle(Tabs.Main, "Auto Rebirth", "AutoRebirth", false)
addToggle(Tabs.Main, "Auto Chests", "AutoChests", false)
addToggle(Tabs.Main, "Auto Brawl", "AutoBrawl", false)

-- KILL
Tabs.Kill:AddParagraph({ Title = "Combat", Content = "Silent Kill recommended | SK2 = aggressive" })
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
    Title = "Glitch Rocks [BETA]",
    Content = "Hit rocks from anywhere • 2x speed • walk/talk free"
})
addToggle(Tabs.Glitch, "Glitch Rocks [BETA]", "GlitchRocks", false)
Tabs.Glitch:AddSlider("GlitchSpeed", {
    Title = "Glitch Punch Speed",
    Default = 2, Min = 1, Max = 5, Rounding = 1,
    Callback = function(v) ML.Settings.GlitchSpeed = v end
})
Tabs.Glitch:AddParagraph({ Title = "Warning", Content = "GLITCH IS IN BETA — may break after updates" })

-- MISC
Tabs.Misc:AddParagraph({ Title = "Quality of life", Content = "Anti AFK / Die / Speed / Counter" })
addToggle(Tabs.Misc, "Anti AFK", "AntiAFK", false)
addToggle(Tabs.Misc, "Anti Die", "AntiDie", false)
addToggle(Tabs.Misc, "Kill Counter UI", "KillCounter", false)
addToggle(Tabs.Misc, "Auto Execute (Delta) — weak", "AutoExecute", false)
Tabs.Misc:AddSlider("WalkSpeed", {
    Title = "WalkSpeed", Default = 16, Min = 16, Max = 120, Rounding = 0,
    Callback = function(v)
        ML.Settings.WalkSpeed = v
        local h = ML.getHum()
        if h then pcall(function() h.WalkSpeed = v end) end
    end
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

-- CREDITS
Tabs.Credits:AddParagraph({
    Title = "ML Script",
    Content = "Creator: Userspin45\nMuscle Legends MEGA FINAL\nSilent Kill • Glitch • Farm"
})
Tabs.Credits:AddParagraph({
    Title = "Warnings",
    Content = "• AUTO EXECUTE DOESNT WORK WELL\n• GLITCH ROCKS IS IN BETA\n• Punch tools only on Fast Punch / Silent Kill"
})
Tabs.Credits:AddParagraph({
    Title = "Links",
    Content = "GitHub: afonsomiguelito13-collab/ML-Script\nScriptBlox: search ML Script"
})

Window:SelectTab(1)

-- ===== BOTÃO PRETO + DRAGÃO (sem texto) =====
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

local ICON_ID = 7999214882 -- dragão Userspin45
local function iconImage()
    if ICON_ID and ICON_ID ~= 0 then
        return string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", ICON_ID)
    end
    return "rbxassetid://7999214882"
end

local btn = Instance.new("ImageButton")
btn.Name = "ToggleBtn"
btn.Size = UDim2.fromOffset(54, 54)
btn.Position = UDim2.new(0, 14, 0.45, 0)
btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
btn.BackgroundTransparency = 0
btn.Image = ""
btn.AutoButtonColor = true
btn.Parent = toggleGui

Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(40, 40, 45)
stroke.Thickness = 1.2
stroke.Parent = btn

local icon = Instance.new("ImageLabel")
icon.Name = "Icon"
icon.BackgroundTransparency = 1
icon.Size = UDim2.fromScale(0.72, 0.72)
icon.Position = UDim2.fromScale(0.14, 0.14)
icon.Image = iconImage()
icon.ScaleType = Enum.ScaleType.Fit
icon.ZIndex = 2
icon.Parent = btn

local dragging, dragStart, startPos
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = btn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local uiOpen = true
local function setFluentVisible(vis)
    pcall(function() if Window.Root then Window.Root.Visible = vis end end)
    pcall(function() if Window.UI then Window.UI.Visible = vis end end)
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
    icon.ImageTransparency = uiOpen and 0 or 0.15
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
end)

print("[ML] parte2 UI + dragon toggle ready ✅"),
