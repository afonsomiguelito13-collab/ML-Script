--[[
    Muscle Legends MEGA FINAL
    Creator: Userspin45
    Loader HTTPS + prints claros
    Repo: https://github.com/afonsomiguelito13-collab/ML-Script
]]

local USER = "afonsomiguelito13-collab"
local REPO = "ML-Script"
local BRANCHES = {"main", "master"}

local function httpGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok and type(result) == "string" and #result > 20 then
        return result
    end
    ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(result) == "string" and #result > 20 then
        return result
    end
    return nil
end

local function loadFromUrl(url, name)
    print("[Userspin45] Baixando: " .. name)
    local source = httpGet(url)
    if not source then
        print("[Userspin45] Não carregou → " .. name .. " (HttpGet falhou)")
        return false
    end

    local fn, err = loadstring(source)
    if not fn then
        print("[Userspin45] Não carregou → " .. name .. " (loadstring: " .. tostring(err) .. ")")
        return false
    end

    local ok, runErr = pcall(fn)
    if not ok then
        print("[Userspin45] Não carregou → " .. name .. " (erro: " .. tostring(runErr) .. ")")
        return false
    end

    print("[Userspin45] Carregou → " .. name)
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
        task.wait(0.25)
    end
    return false
end

print("========================================")
print("[Userspin45] Loader MEGA FINAL")
print("========================================")

local ok1 = loadPart("part1.lua")
local ok2 = false
local ok3 = false

if ok1 then
    task.wait(0.15)
    ok2 = loadPart("part2.lua")
end

if ok2 then
    task.wait(0.15)
    ok3 = loadPart("part3.lua")
end

print("========================================")
if ok1 and ok2 and ok3 then
    print("[Userspin45] Carregou tudo ✅")
    print("[Userspin45] MEGA FINAL pronto!")
else
    print("[Userspin45] Não carregou ❌")
    print("part1 = " .. (ok1 and "OK" or "FALHOU"))
    print("part2 = " .. (ok2 and "OK" or "FALHOU"))
    print("part3 = " .. (ok3 and "OK" or "FALHOU"))
    print("Verifica se os ficheiros estão no GitHub (raiz, branch main)")
end
print("========================================")
