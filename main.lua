--[[
    Muscle Legends MEGA FINAL
    Creator: Userspin45
    main.lua completo + DEBUG
    Repo: https://github.com/afonsomiguelito13-collab/ML-Script
]]

print("========================================")
print("[Userspin45] main.lua iniciado")
print("========================================")

local USER = "afonsomiguelito13-collab"
local REPO = "ML-Script"
local BRANCHES = {"main", "master"}

-- nomes em português (como tu meteste)
local PARTES = {
    "parte1.lua",
    "parte2.lua",
    "parte3.lua",
}

local function httpGet(url)
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok and type(res) == "string" and #res > 30 then
        return res
    end
    ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(res) == "string" and #res > 30 then
        return res
    end
    return nil
end

local function loadParte(nome)
    for _, branch in ipairs(BRANCHES) do
        local url = string.format(
            "https://raw.githubusercontent.com/%s/%s/%s/%s?t=%d",
            USER, REPO, branch, nome, os.time()
        )
        print("[DEBUG] Baixando: " .. branch .. "/" .. nome)

        local source = httpGet(url)
        if not source then
            print("[DEBUG] ❌ HttpGet falhou → " .. nome)
        else
            print("[DEBUG] ✅ Download OK → " .. nome .. " | " .. #source .. " chars")

            local fn, err = loadstring(source)
            if not fn then
                print("[DEBUG] ❌ loadstring falhou → " .. nome)
                print("[DEBUG] Erro: " .. tostring(err))
            else
                local ok, runErr = pcall(fn)
                if not ok then
                    print("[DEBUG] ❌ Erro ao executar → " .. nome)
                    print("[DEBUG] Erro: " .. tostring(runErr))
                else
                    print("[DEBUG] ✅ Carregou → " .. nome)
                    return true
                end
            end
        end
        task.wait(0.2)
    end
    return false
end

print("[Userspin45] A carregar as 3 partes...")

local ok1 = loadParte(PARTES[1])
local ok2 = false
local ok3 = false

if ok1 then
    task.wait(0.15)
    ok2 = loadParte(PARTES[2])
end

if ok2 then
    task.wait(0.15)
    ok3 = loadParte(PARTES[3])
end

print("========================================")
if ok1 and ok2 and ok3 then
    print("[Userspin45] Carregou tudo ✅")
    print("[Userspin45] MEGA FINAL pronto!")
else
    print("[Userspin45] Não carregou ❌")
    print("parte1 = " .. (ok1 and "OK" or "FALHOU"))
    print("parte2 = " .. (ok2 and "OK" or "FALHOU"))
    print("parte3 = " .. (ok3 and "OK" or "FALHOU"))
    print("Confirma no GitHub os nomes: parte1.lua | parte2.lua | parte3.lua")
end
print("========================================")
