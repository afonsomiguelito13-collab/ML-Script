print("[Userspin45] main FIX 🧠")
local base = "https://raw.githubusercontent.com/afonsomiguelito13-collab/ML-Script/main/"
local t = tostring(os.time())
local function load(f)
    print(">> "..f)
    local src = game:HttpGet(base..f.."?t="..t)
    print("chars="..#src)
    local fn, err = loadstring(src)
    if not fn then print("ERRO loadstring:", err) return false end
    local ok, e = pcall(fn)
    if not ok then print("ERRO exec:", e) return false end
    print("OK ✅ "..f)
    return true
end
local a = load("parte1.lua")
task.wait(0.2)
local b = a and load("parte2.lua")
task.wait(0.2)
local c = b and load("parte3.lua")
print(c and "[Userspin45] Carregou tudo ✅" or "[Userspin45] Não carregou ❌")
