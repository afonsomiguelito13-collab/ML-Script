--[[ parte3.lua — Loops + Glitch + Final | Userspin45 ]]

local U = getgenv().Userspin45
if not U or not U.Fluent or not U.Window then
    warn("[Userspin45] parte1/parte2 não carregaram!")
    return
end

local Config = U.Config
local Fluent = U.Fluent
local VU = game:GetService("VirtualUser")

task.spawn(function()
    while true do
        if Config.AutoStrength then U.doStrength() U.setAnim(Config.AnimSpeed) end
        if Config.FastPunch and not Config.SilentKill and not Config.SilentKill2 and not Config.GlitchRock then
            U.doPunch() U.setAnim(Config.AnimSpeed)
        end
        task.wait(0.35)
    end
end)

task.spawn(function()
    local last = nil
    while true do
        if Config.SilentKill and not Config.SilentKill2 then
            pcall(function()
                if last and U.dead(last) then
                    U.killCount = U.killCount + 1
                    U.updateCounter()
                    last = nil
                    U.currentTarget = nil
                end
                if not U.currentTarget or U.dead(U.currentTarget) then
                    U.currentTarget = U.getNearest() or U.getRandom()
                    if U.currentTarget then U.tp(U.currentTarget) last = U.currentTarget end
                else
                    U.tp(U.currentTarget) last = U.currentTarget
                end
                U.doPunch()
                U.setAnim(Config.AnimSpeed)
                if Config.AutoServerHop and U.aliveCount() == 0 then
                    task.wait(0.8)
                    if U.aliveCount() == 0 then U.hop() end
                end
            end)
        end
        task.wait(0.22)
    end
end)

task.spawn(function()
    local last = nil
    while true do
        if Config.SilentKill2 or Config.KillAura then
            pcall(function()
                U.refresh()
                if not U.HRP then return end
                if last and U.dead(last) then
                    U.killCount = U.killCount + 1
                    U.updateCounter()
                    last = nil
                    U.currentTarget = nil
                end
                local aura = U.inAura()
                if #aura > 0 then
                    local n, d = nil, math.huge
                    for _, p in ipairs(aura) do
                        local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            local dist = (U.HRP.Position - r.Position).Magnitude
                            if dist < d then d, n = dist, p end
                        end
                    end
                    if n then U.currentTarget = n last = n U.tp(n) end
                    U.doPunch()
                elseif Config.SilentKill2 then
                    if not U.currentTarget or U.dead(U.currentTarget) then
                        U.currentTarget = U.getNearest() or U.getRandom()
                        if U.currentTarget then U.tp(U.currentTarget) last = U.currentTarget end
                    else
                        U.tp(U.currentTarget) last = U.currentTarget
                    end
                    U.doPunch()
                end
                U.setAnim(Config.AnimSpeed)
                if Config.AutoServerHop and Config.SilentKill2 and U.aliveCount() == 0 then
                    task.wait(0.8)
                    if U.aliveCount() == 0 then U.hop() end
                end
            end)
        end
        task.wait(0.18)
    end
end)

-- GLITCH ROCK
task.spawn(function()
    while true do
        if Config.GlitchRock then
            pcall(function()
                U.doGlitchRock()
                U.setAnim(Config.GlitchSpeed or 2)
            end)
            local spd = Config.GlitchSpeed or 2
            task.wait(math.max(0.08, 0.28 / spd))
        else
            task.wait(0.3)
        end
    end
end)

task.spawn(function() while true do if Config.AutoRebirth then U.doRebirth() end task.wait(0.8) end end)
task.spawn(function() while true do if Config.AutoChests then U.doChests() end task.wait(1.5) end end)
task.spawn(function() while true do if Config.AutoBrawl then U.doBrawl() end task.wait(2) end end)

task.spawn(function()
    while true do
        if Config.AntiAFK then
            pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
        end
        task.wait(25)
    end
end)

task.spawn(function()
    while true do
        if Config.AntiDie then
            U.refresh()
            if U.Hum and U.Hum.Health < U.Hum.MaxHealth * 0.4 then
                U.Hum.Health = U.Hum.MaxHealth
            end
        end
        task.wait(0.4)
    end
end)

pcall(function()
    if U.SaveManager and U.InterfaceManager then
        U.SaveManager:SetLibrary(Fluent)
        U.InterfaceManager:SetLibrary(Fluent)
        U.SaveManager:IgnoreThemeSettings()
        U.InterfaceManager:SetFolder("Userspin45ML")
        U.SaveManager:SetFolder("Userspin45ML")
        U.InterfaceManager:BuildInterfaceSection(U.Tabs.Credits)
        U.SaveManager:BuildConfigSection(U.Tabs.Credits)
    end
end)

U.Window:SelectTab(1)
Fluent:Notify({ Title = "Userspin45", Content = "MEGA FINAL + Glitch carregado!", Duration = 5 })
print("[Userspin45] parte3 OK — MEGA FINAL ready!")
