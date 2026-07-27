-- ML Script | parte1.lua
-- Shared state, remotes, equip helpers (Userspin45)
print("[ML] parte1 shared ✅")

getgenv().ML = getgenv().ML or {}
local ML = getgenv().ML

ML.Version = "MEGA-FINAL"
ML.Creator = "Userspin45"

-- ===== FLAGS =====
ML.Flags = ML.Flags or {
    AutoLift = false,
    FastPunch = false,
    AutoStrength = false,
    AutoRebirth = false,
    AutoChests = false,
    AutoBrawl = false,
    SilentKill = false,
    SilentKill2 = false,
    KillAura = false,
    GlitchRocks = false,
    AntiAFK = false,
    AntiDie = false,
    AutoExecute = false,
    KillCounter = false,
}

ML.Settings = ML.Settings or {
    AuraSize = 15,
    WalkSpeed = 16,
    GlitchSpeed = 2,
}

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

ML.LP = Players.LocalPlayer

-- ===== REMOTES (safe) =====
ML.Remotes = ML.Remotes or {}

local function findRemote()
    local pe = ML.LP:FindFirstChild("muscleEvent")
    if pe then ML.Remotes.muscleEvent = pe end

    local rEvents = RS:FindFirstChild("rEvents")
    if rEvents then
        local reb = rEvents:FindFirstChild("rebirthRemote")
        if reb then ML.Remotes.rebirthRemote = reb end
    end

    pcall(function()
        for _, v in ipairs(RS:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local n = string.lower(v.Name)
                if n:find("rebirth") and not ML.Remotes.rebirthRemote then
                    ML.Remotes.rebirthRemote = v
                end
                if n:find("muscle") and v:IsA("RemoteEvent") and not ML.Remotes.muscleEvent then
                    ML.Remotes.muscleEvent = v
                end
            end
        end
    end)
end
findRemote()

-- ===== TOOL NAMES =====
ML.PunchNames = {
    "Punch", "punch", "Fist", "Fists", "Combat", "Hand"
}

ML.TrainNames = {
    "Handstands", "Situps", "Pushups", "Weight", "Weights",
    "Dumbbell", "Barbell", "Training"
}

local function nameMatch(toolName, list)
    local t = string.lower(toolName or "")
    for _, n in ipairs(list) do
        if t == string.lower(n) or t:find(string.lower(n), 1, true) then
            return true
        end
    end
    return false
end

function ML.unequipAll()
    local char = ML.LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:UnequipTools() end) end
end

function ML.equipPunch()
    local char = ML.LP.Character
    local bag = ML.LP:FindFirstChild("Backpack")
    if not char or not bag then return false end
    ML.unequipAll()
    for _, v in ipairs(bag:GetChildren()) do
        if v:IsA("Tool") and nameMatch(v.Name, ML.PunchNames) then
            v.Parent = char
            return true
        end
    end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") and nameMatch(v.Name, ML.PunchNames) then
            return true
        end
    end
    return false
end

function ML.equipTrain()
    local char = ML.LP.Character
    local bag = ML.LP:FindFirstChild("Backpack")
    if not char or not bag then return end
    for _, v in ipairs(bag:GetChildren()) do
        if v:IsA("Tool") and nameMatch(v.Name, ML.TrainNames) then
            v.Parent = char
        end
    end
end

function ML.fireRep()
    local rem = ML.Remotes.muscleEvent
    if rem then
        pcall(function()
            rem:FireServer("rep")
        end)
    end
end

function ML.fireRebirth()
    local rem = ML.Remotes.rebirthRemote
    if rem then
        pcall(function()
            if rem:IsA("RemoteFunction") then
                rem:InvokeServer("rebirthRequest")
            else
                rem:FireServer("rebirthRequest")
            end
        end)
    end
end

function ML.getHRP()
    local c = ML.LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

function ML.getHum()
    local c = ML.LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

ML.RockNames = {
    "Rock", "Golden Rock", "Rock of Legends", "Muscle King Rock",
    "Punching Rock", "Training Rock", "Tiny Rock", "Legend Rock",
    "Frost Rock", "Eternal Rock", "Mythical Rock", "Green Rock",
    "Strength Rock", "Durability Rock", "King Rock"
}

print("[ML] parte1 ready | rebirths vibe | equipPunch only Punch")
