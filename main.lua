--[[
    Muscle Legends MEGA FINAL
    Creator: Userspin45
    main.lua — carrega parte1 / parte2 / parte3
    Repo: https://github.com/afonsomiguelito13-collab/ML-Script
]]

print("========================================")
print("[Userspin45] main.lua iniciado")
print("========================================")

local USER = "afonsomiguelito13-collab"
local REPO = "ML-Script"
local REF = "main"

local PARTES = {
    "parte1.lua",
    "parte2.lua",
    "parte3.lua",
}

local function httpGet(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(res) == "string" and #res > 30 then
        return res
    end
    return nil
end

local function loadParte(nome)
    local urls = {
        -- jsDelivr (melhor no Delta — evita Https Failed)
        string.format("https://cdn.jsdelivr.net/gh/%s/%s@%s/%s", USER, REPO, REF, nome),
        string.format("https://cdn.jsdelivr.net/gh/%s/%s@master/%s", USER, REPO, nome),
        -- raw github fallback
        string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", USER, REPO, REF, nome),
        string.format("https://raw.githubusercontent.com/%s/%s/master/%s", USER, REPO, nome),
    }

    for _, url in ipairs(urls) do
        print("[DEBUG] Baixando: " .. nome)
        local src = httpGet(url .. "?t=" .. tostring(os.time()))
        if src then
            print("[DEBUG] ✅ Download OK → " .. nome .. " | " .. #src .. " chars")
            local fn, err = loadstring(src)
            if not fn then
                print("[DEBUG] ❌ loadstring → " .. nome .. " | " .. tostring(err))
            else
                local ok, runErr = pcall(fn)
                if ok then
                    print("[DEBUG] ✅ Carregou → " .. nome)
                    return true
                else
                    print("[DEBUG] ❌ Executar → " .. nome .. " | " .. tostring(runErr))
                end
            end
        else
            print("[DEBUG] ❌ HttpGet falhou → " .. nome)
        end
        task.wait(0.15)
    end
    return false
end

print("[Userspin45] A carregar as 3 partes (updates)...")

local ok1 = loadParte(PARTES[1])
local ok2 = false
local ok3 = false

if ok1 then
    task.wait(0.2)
    ok2 = loadParte(PARTES[2])
end

if ok2 then
    task.wait(0.2)
    ok3 = loadParte(PARTES[3])
end

print("========================================")
if ok1 and ok2 and ok3 then
    print("[Userspin45] Carregou tudo ✅")
    print("[Userspin45] MEGA FINAL + updates pronto!")
else
    print("[Userspin45] Não carregou ❌")
    print("parte1 = " .. (ok1 and "OK" or "FALHOU"))
    print("parte2 = " .. (ok2 and "OK" or "FALHOU"))
    print("parte3 = " .. (ok3 and "OK" or "FALHOU"))
    print("Confirma no GitHub: parte1.lua | parte2.lua | parte3.lua")
end
print("========================================")
