--[[
    Muscle Legends MEGA FINAL
    Creator: Userspin45
    Loader — carrega part1 + part2 + part3
    Repo: https://github.com/afonsomiguelito13-collab/ML-Script
]]

local base = "https://raw.githubusercontent.com/afonsomiguelito13-collab/ML-Script/main/"

local function loadPart(name)
    local url = base .. name
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("[Userspin45] Falha ao carregar " .. name .. " → " .. tostring(result))
        return false
    end
    print("[Userspin45] " .. name .. " carregado!")
    return true
end

print("[Userspin45] Iniciando loader...")

if loadPart("part1.lua") then
    if loadPart("part2.lua") then
        loadPart("part3.lua")
    end
end

print("[Userspin45] MEGA FINAL carregado com sucesso!")
