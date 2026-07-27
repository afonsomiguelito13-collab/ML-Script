-- ML Script | Userspin45
-- Loader (parte1 -> parte2 -> parte3)
print("[Userspin45] ML Script loader 🧠")

local base = "https://raw.githubusercontent.com/afonsomiguelito13-collab/ML-Script/main/"
local t = tostring(os.time())

local function loadPart(name)
    print(">> loading " .. name)
    local okGet, src = pcall(function()
        return game:HttpGet(base .. name .. "?t=" .. t)
    end)
    if not okGet or not src or #src < 50 then
        print("ERRO HttpGet:", name, okGet and "empty" or tostring(src))
        return false
    end
    print("chars=" .. #src)
    local fn, err = loadstring(src)
    if not fn then
        print("ERRO loadstring:", err)
        return false
    end
    local ok, e = pcall(fn)
    if not ok then
        print("ERRO exec:", e)
        return false
    end
    print("OK ✅ " .. name)
    return true
end

local a = loadPart("parte1.lua")
task.wait(0.15)
local b = a and loadPart("parte2.lua")
task.wait(0.15)
local c = b and loadPart("parte3.lua")

if c then
    print("[Userspin45] Carregou tudo ✅ ML Script")
else
    print("[Userspin45] Não carregou ❌ checa raw GitHub / internet")
end
