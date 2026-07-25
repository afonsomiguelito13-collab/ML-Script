--[[ parte2.lua — UI + Glitch Tab | Userspin45 ]]

local U = getgenv().Userspin45
if not U or not U.Fluent then
    warn("[Userspin45] parte1 não carregou!")
    return
end

local Fluent = U.Fluent
local Config = U.Config

local Window = Fluent:CreateWindow({
    Title = "ML Userspin45",
    SubTitle = "MEGA FINAL",
    TabWidth = 130,
    Size = UDim2.fromOffset(520, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "zap" }),
    Kill = Window:AddTab({ Title = "Kill", Icon = "swords" }),
    Glitch = Window:AddTab({ Title = "Glitch", Icon = "sparkles" }),
    TP = Window:AddTab({ Title = "TP", Icon = "map" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Credits = Window:AddTab({ Title = "Credits", Icon = "user" })
}
U.Tabs = Tabs
U.Window = Window

-- MAIN
Tabs.Main:AddToggle("AS", {
    Title = "Auto Strength (Auto Lift)",
    Description = "Só Weight / Pushups / Situps / Handstands",
    Default = false,
    Callback = function(v)
        Config.AutoStrength = v
        if v then U.setAnim(Config.AnimSpeed) else U.setAnim(1) end
    end
})
Tabs.Main:AddToggle("FP", {
    Title = "Fast Punch",
    Description = "Só Punch",
    Default = false,
    Callback = function(v)
        Config.FastPunch = v
        if v then U.equipPunch() end
    end
})
Tabs.Main:AddSlider("ASPD", {
    Title = "Anim Speed", Default = 1.5, Min = 1, Max = 3.5, Rounding = 1,
    Callback = function(v)
        Config.AnimSpeed = v
        if Config.AutoStrength or Config.FastPunch or Config.SilentKill or Config.SilentKill2 then
            U.setAnim(v)
        end
    end
})
Tabs.Main:AddButton({ Title = "Turn Small", Callback = function() U.setSize(1) end })

-- FARM
Tabs.Farm:AddToggle("AR", { Title = "Auto Rebirth", Default = false, Callback = function(v) Config.AutoRebirth = v end })
Tabs.Farm:AddToggle("AC", { Title = "Auto Chests", Default = false, Callback = function(v) Config.AutoChests = v end })
Tabs.Farm:AddToggle("AB", { Title = "Auto Brawl", Default = false, Callback = function(v) Config.AutoBrawl = v end })
Tabs.Farm:AddSection("Crystals")
for _, n in ipairs({"Blue Crystal","Green Crystal","Mythical Crystal","Frost Crystal","Inferno Crystal","Legends Crystal","Muscle Elite Crystal"}) do
    Tabs.Farm:AddButton({ Title = n, Callback = function() U.openCrystal(n) end })
end

-- KILL
Tabs.Kill:AddParagraph({ Title = "Kill System", Content = "Silent Kill = recomendado\nSilent Kill 2 = odiado (Aura)" })
U.KillLabel = Tabs.Kill:AddParagraph({ Title = "Kill Counter", Content = "Kills: 0" })

Tabs.Kill:AddToggle("SK", {
    Title = "Silent Kill (Recomendado)",
    Description = "Só Punch + TP + hop",
    Default = false,
    Callback = function(v)
        Config.SilentKill = v
        if v then
            Config.SilentKill2 = false
            U.currentTarget = nil
            U.equipPunch()
            U.setAnim(Config.AnimSpeed)
            Fluent:Notify({ Title = "Silent Kill", Content = "ON | Só Punch", Duration = 2 })
        else
            U.currentTarget = nil
        end
    end
})
Tabs.Kill:AddToggle("SK2", {
    Title = "Silent Kill 2 (Odiado)",
    Description = "Aura + TP + só Punch",
    Default = false,
    Callback = function(v)
        Config.SilentKill2 = v
        if v then
            Config.SilentKill = false
            Config.KillAura = true
            U.currentTarget = nil
            U.equipPunch()
            U.setAnim(Config.AnimSpeed)
            Fluent:Notify({ Title = "Silent Kill 2", Content = "ON", Duration = 2 })
        else
            Config.KillAura = false
            U.currentTarget = nil
        end
    end
})
Tabs.Kill:AddToggle("KA", {
    Title = "Kill Aura", Default = false,
    Callback = function(v) Config.KillAura = v if v then U.equipPunch() end end
})
Tabs.Kill:AddSlider("ASize", {
    Title = "Aura Size", Default = 12, Min = 5, Max = 40, Rounding = 0,
    Callback = function(v) Config.AuraSize = v end
})
Tabs.Kill:AddToggle("ASH", {
    Title = "Auto Server Hop", Default = true,
    Callback = function(v) Config.AutoServerHop = v end
})
Tabs.Kill:AddButton({ Title = "Reset Counter", Callback = function() U.killCount = 0 U.updateCounter() end })
Tabs.Kill:AddButton({ Title = "TP Nearest", Callback = function() local p = U.getNearest() if p then U.tp(p) end end })
Tabs.Kill:AddButton({ Title = "Force Hop", Callback = function() U.hop() end })

-- GLITCH
Tabs.Glitch:AddParagraph({
    Title = "Glitch Rocks",
    Content = "Bate nas pedras SEM estar lá.\nPodes andar e falar. Speed 2x."
})
Tabs.Glitch:AddToggle("GlitchRock", {
    Title = "Auto Hit Rock (Glitch)",
    Description = "Punch remoto infinito",
    Default = false,
    Callback = function(v)
        Config.GlitchRock = v
        if v then
            U.equipPunch()
            U.setAnim(Config.GlitchSpeed or 2)
            Fluent:Notify({ Title = "Glitch Rock", Content = "ON | " .. tostring(Config.GlitchRockName), Duration = 3 })
        else
            U.setAnim(1)
        end
    end
})
Tabs.Glitch:AddSlider("GlitchSpd", {
    Title = "Punch Speed (Glitch)", Default = 2, Min = 1, Max = 4, Rounding = 1,
    Callback = function(v)
        Config.GlitchSpeed = v
        if Config.GlitchRock then U.setAnim(v) end
    end
})

local rockOptions = U.ROCK_NAMES or {
    "Tiny Rock", "Punching Rock", "Large Rock", "Golden Rock",
    "Frozen Rock", "Mythical Rock", "Eternal Rock", "Legends Rock",
    "Jungle Rock", "Ancient Jungle Rock", "Muscle King Rock"
}
Tabs.Glitch:AddDropdown("RockSelect", {
    Title = "Pedra",
    Values = rockOptions,
    Multi = false,
    Default = 2,
    Callback = function(v)
        local name = type(v) == "table" and (v[1] or v.Value) or v
        if type(name) == "string" then
            Config.GlitchRockName = name
            Fluent:Notify({ Title = "Pedra", Content = name, Duration = 2 })
        end
    end
})
Tabs.Glitch:AddButton({
    Title = "TP até à pedra",
    Callback = function()
        local rock = U.findRock(Config.GlitchRockName or "Punching Rock")
        U.refresh()
        if rock and U.HRP then
            U.HRP.CFrame = rock.CFrame + Vector3.new(0, 3, 5)
        else
            Fluent:Notify({ Title = "Glitch", Content = "Pedra não encontrada", Duration = 3 })
        end
    end
})
Tabs.Glitch:AddButton({
    Title = "Scan rocks (console)",
    Callback = function()
        local found = {}
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("rock") then
                    table.insert(found, obj.Name)
                end
            end
        end)
        print("[Userspin45] Rocks:")
        for _, n in ipairs(found) do print(" - " .. n) end
        Fluent:Notify({ Title = "Scan", Content = #found .. " rocks (F9)", Duration = 4 })
    end
})
Tabs.Glitch:AddParagraph({
    Title = "Dica Pet Glitch",
    Content = "Pet 0 XP → Auto Hit Rock na pedra certa → deixa bater."
})

-- TP
for _, t in ipairs({
    { n = "Legends Gym", c = CFrame.new(4298.6, 1121.9, -3898.7) },
    { n = "Mythical Gym", c = CFrame.new(2386.9, 139.6, 1094.3) },
    { n = "Frost Gym", c = CFrame.new(-2752.6, 125.8, -386.7) },
    { n = "Eternal Gym", c = CFrame.new(-6917.8, 182.4, -1336.6) },
    { n = "Tiny Island", c = CFrame.new(-4.3, 221, 1963.6) },
    { n = "Brawl 1", c = CFrame.new(985.9, 163.8, -7037.8) },
    { n = "Brawl 2", c = CFrame.new(4466.8, 335, -8425.7) },
    { n = "Brawl 3", c = CFrame.new(-1901.9, 251.9, -5899.6) },
}) do
    Tabs.TP:AddButton({
        Title = t.n,
        Callback = function() U.refresh() if U.HRP then U.HRP.CFrame = t.c end end
    })
end

-- MISC
Tabs.Misc:AddToggle("AAFK", { Title = "Anti AFK", Default = false, Callback = function(v) Config.AntiAFK = v end })
Tabs.Misc:AddToggle("AD", { Title = "Anti Die", Default = false, Callback = function(v) Config.AntiDie = v end })
Tabs.Misc:AddSlider("WS", {
    Title = "WalkSpeed", Default = 16, Min = 16, Max = 200, Rounding = 0,
    Callback = function(v) U.refresh() if U.Hum then U.Hum.WalkSpeed = v end end
})
Tabs.Misc:AddButton({ Title = "Full Health", Callback = function() U.refresh() if U.Hum then U.Hum.Health = U.Hum.MaxHealth end end })
Tabs.Misc:AddButton({ Title = "Rejoin", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer) end })
Tabs.Misc:AddSection("Delta AutoExecute")
Tabs.Misc:AddToggle("AutoExec", {
    Title = "Auto Execute (Delta)",
    Description = "ON = grava | OFF = remove",
    Default = false,
    Callback = function(v)
        Config.AutoExecute = v
        if U.setAutoExecute then U.setAutoExecute(v) end
    end
})
Tabs.Misc:AddParagraph({
    Title = "Info",
    Content = "Auto Execute ON → depois do hop o Delta tenta carregar sozinho."
})

-- CREDITS
Tabs.Credits:AddParagraph({
    Title = "Creator",
    Content = "👑 Userspin45\nMEGA FINAL + Glitch Rocks\nSilent Kill só Punch"
})
Tabs.Credits:AddButton({
    Title = "Copiar Credits",
    Callback = function() setclipboard("Creator: Userspin45 | ML MEGA FINAL") end
})

print("[Userspin45] parte2 OK")
