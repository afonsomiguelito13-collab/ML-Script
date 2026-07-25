--[[
    Muscle Legends MEGA FINAL
    Creator: Userspin45
    main.lua — jsDelivr (fix Https Failed)
]]

print("[Userspin45] main.lua iniciado (jsDelivr)")

local USER = "afonsomiguelito13-collab"
local REPO = "ML-Script"
local REF = "main" -- ou "master"

local PARTES = {"parte1.lua", "parte2.lua", "parte3.lua"}

local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" and #res > 30 then return res end
    return nil
end

local function loadParte(nome)
    local urls = {
        string.format("https://cdn.jsdelivr.net/gh/%s/%s@%s/%s", USER, REPO, REF, nome),
        string.format("https://cdn.jsdelivr.net/gh/%s/%s@master/%s", USER, REPO, nome),
        string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", USER, REPO, REF, nome),
    }
    for _, url in ipairs(urls) do
        print("[DEBUG] Baixando: " .. nome)
        local src = httpGet(url .. "?t=" .. tostring(tick()))
        if src then
            print("[DEBUG] ✅ " .. nome .. " | " .. #src .. " chars")
            local fn, err = loadstring(src)
            if fn then
                local ok, e = pcall(fn)
                if ok then
                    print("[DEBUG] ✅ Carregou → " .. nome)
                    return true
                end
                print("[DEBUG] ❌ Executar " .. nome .. ": " .. tostring(e))
            else
                print("[DEBUG] ❌ loadstring " .. nome .. ": " .. tostring(err))
            end
        else
            print("[DEBUG] ❌ Falhou URL → " .. nome)
        end
        task.wait(0.15)
    end
    return false
end

local ok1 = loadParte(PARTES[1])
local ok2 = ok1 and loadParte(PARTES[2])
local ok3 = ok2 and loadParte(PARTES[3])

print("========================================")
if ok1 and ok2 and ok3 then
    print("[Userspin45] Carregou tudo ✅")
else
    print("[Userspin45] Não carregou ❌")
    print("parte1=" .. (ok1 and "OK" or "FALHOU") .. " | parte2=" .. (ok2 and "OK" or "FALHOU") .. " | parte3=" .. (ok3 and "OK" or "FALHOU"))
end
print("========================================")
