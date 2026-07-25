--[[
    Muscle Legends MEGA FINAL
    Creator: Userspin45
    Loader com HTTPS + fallback + retry
    Repo: https://github.com/afonsomiguelito13-collab/ML-Script
]]

local USER = "afonsomiguelito13-collab"
local REPO = "ML-Script"
local BRANCHES = {"main", "master"} -- tenta os dois

local function httpGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url, true) -- true = cache disable (alguns executors)
    end)
    if ok and result and #result > 10 then
        return result
    end
    -- fallback sem 2º argumento
    ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and result and #result > 10 then
        return result
    end
    return nil
end

local function loadFromUrl(url, name)
    print("[Userspin45] Tentando: " .. url)
    local source = httpGet(url)
    if not source then
        warn("[Userspin45] HttpGet falhou → " .. name)
        return false
    end

    local fn, err = loadstring(source)
    if not fn then
        warn("[Userspin45] loadstring falhou → " .. name .. " | " .. tostring(err))
        return false
    end

    local ok, runErr = pcall(fn)
    if not ok then
        warn("[Userspin45] Erro ao executar → " .. name .. " | " .. tostring(runErr))
        return false
    end

    print("[Userspin45] OK → " .. name)
    return true
end

local function loadPart(name)
    for _, branch in ipairs(BRANCHES) do
        local url = string.format(
            "https://raw.githubusercontent.com/%s/%s/%s/%s?t=%d",
            USER, REPO, branch, name, os.time()
        )
        if loadFromUrl(url, name) then
            return true
        end
        task.wait(0.3)
    end
    return false
end

print("========================================")
print("[Userspin45] Loader MEGA FINAL iniciando...")
print("========================================")

local ok1 = loadPart("part1.lua")
if not ok1 then
    warn("[Userspin45] part1.lua NÃO carregou. Verifica se o ficheiro está no GitHub.")
    return
end

task.wait(0.2)

local ok2 = loadPart("part2.lua")
if not ok2 then
    warn("[Userspin45] part2.lua NÃO carregou.")
    return
end

task.wait(0.2)

local ok3 = loadPart("part3.lua")
if not ok3 then
    warn("[Userspin45] part3.lua NÃO carregou.")
    return
end

print("========================================")
print("[Userspin45] MEGA FINAL carregado com sucesso!")
print("========================================")
