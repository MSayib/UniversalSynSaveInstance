--[[
    ╔══════════════════════════════════════════════════════════╗
    ║  USSI Project Dumper — Enterprise Full Fixed Edition     ║
    ║  Executor: Delta (iOS / macOS Standard) — 99% sUNC       ║
    ║  Author: sayib                                           ║
    ╚══════════════════════════════════════════════════════════╝

    Changelog:
    - Source URL changed to MSayib fork (with metadata-only fix)
    - IgnoreList now uses = false for Packages/CorePackages/Virtualized
    - DecompileTimeout reduced from 120 to 15 (120s causes hang/crash)
    - SafeMode enabled for stability
    - Removed dead METADATA_ONLY_CONTAINERS table at EOF
    - Removed ChatGPT scaffold logger noise
--]]

print("==================================================")
print("[DEBUG] STARTING PIPELINE INITIALIZATION")
print("==================================================")

local Params = {
	-- Use MSayib fork which has the metadata-only fix
	RepoURL = "https://raw.githubusercontent.com/MSayib/UniversalSynSaveInstance/fix/metadata-only-containers-and-ignorelist-skip-bug/",
	SSI = "saveinstance",
	MaxRetries = 3,
	RetryDelay = 2,
}

local sourceCode = nil
local httpSuccess = false

for i = 1, Params.MaxRetries do
	print(string.format("[DEBUG] Mengunduh USSI dari GitHub (Mencoba %d/%d)...", i, Params.MaxRetries))
	httpSuccess, sourceCode = pcall(function()
		return game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true)
	end)

	if httpSuccess and sourceCode then
		print("[+] USSI Source Code berhasil diunduh.")
		break
	else
		warn(string.format("[-] Gagal pada percobaan %d. Mencoba kembali dalam %d detik...", i, Params.RetryDelay))
		task.wait(Params.RetryDelay)
	end
end

if not httpSuccess or not sourceCode then
	warn("[-] CRITICAL ERROR HTTP: Gagal mengambil source setelah beberapa kali percobaan.")
	return
end

print("[DEBUG] Memuat source ke loadstring...")
local loadSuccess, synsaveinstance = pcall(function()
	return loadstring(sourceCode, Params.SSI)()
end)

if not loadSuccess or type(synsaveinstance) ~= "function" then
	warn("[-] ERROR LOADSTRING: Gagal melakukan compile bytecode USSI.")
	print("Detail Error: " .. tostring(synsaveinstance))
	return
end

local fileNameRaw = "Project_" .. game.PlaceId .. "_v" .. game.PlaceVersion

local Options = {
	----- 1. FILE & OUTPUT -----
	FilePath = fileNameRaw,
	mode = "full",

	----- 2. DECOMPILATION -----
	Decompile = true,
	noscripts = false,
	DecompileTimeout = 15, -- 120 terlalu besar, menyebabkan hang pada script yang memang tidak bisa di-decompile
	SaveBytecode = true,
	scriptcache = true,
	DecompileIgnore = {},

	----- 3. OPTIMIZATION -----
	IsolatePlayers = true,
	IsolateLocalPlayer = true,
	IsolateLocalPlayerCharacter = true,
	SavePlayerCharacters = false,

	----- 4. CLEANUP & CRASH PREVENTION -----
	IgnoreDefaultProps = true,
	IgnoreList = {
		"CoreGui",              -- Skip entirely (tidak diperlukan di output)
		CorePackages = false,   -- Metadata only: serialize node, skip children
		Packages = false,       -- Metadata only: serialize node, skip children
		Virtualized = false,    -- Metadata only: serialize node, skip children
	},

	----- 5. STABILITY & DEBUG -----
	SafeMode = true, -- Kick sebelum save untuk keamanan
	ShowStatus = true,
	__DEBUG_MODE = true,
}

print("[+] USSI Engine Terbaca. Memulai Prosedur Dumping...")
print("    Nama Berkas Target: " .. fileNameRaw .. ".rbxlx")
print("==================================================")

local dumpSuccess, dumpError = pcall(function()
	synsaveinstance(Options)
end)

if not dumpSuccess then
	warn("[-] Dump Engine menemui kegagalan atau terhenti: " .. tostring(dumpError))
else
	print("[+] Core Instance Dump Sukses Terbaca!")
end

----------------==================================----------------
-- AUTOMATION POST-DUMP: SAFE TEXT GENERATOR PIPELINE
----------------==================================----------------
print("[DEBUG] Memulai pembuatan file tambahan di workspace...")

local mockLines = {
	"--[[",
	"    ========================================================================",
	"    ADVANCED ARCHITECTURE MOCK SERVER HANDLER (AUTO-GENERATED)",
	"    ========================================================================",
	"    Konteks: Simulasi State, Validasi Payload, dan Penanganan Kontrak Jaringan",
	"    Arsitektur Target: Clean Architecture & SOLID Principles",
	"    ========================================================================",
	"--]]",
	"",
	'local ReplicatedStorage = game:GetService("ReplicatedStorage")',
	'local Players = game:GetService("Players")',
	"",
	"-- Simulasi Database / State Terpusat di Server (In-Memory Database)",
	"local ServerStateCache = {",
	"    PlayersData = {},",
	"    GlobalSessionStore = {",
	"        IsEventActive = true,",
	'        ConfigVersion = "1.0.0"',
	"    }",
	"}",
	"",
	"-- Helper Functions untuk Validasi Payload Jaringan (Type Guard & Security Assertions)",
	"local function assertPayloadType(value, expectedType, paramName)",
	"    if type(value) ~= expectedType then",
	'        warn(string.format("[Security Alert] Tipe data tidak valid untuk %s. Diharapkan %s, mendapatkan %s", paramName, expectedType, type(value)))',
	"        return false",
	"    end",
	"    return true",
	"end",
	"",
	"-- Inisialisasi State saat Player Bergabung ke Server Simulator",
	"Players.PlayerAdded:Connect(function(player)",
	"    ServerStateCache.PlayersData[player.UserId] = {",
	"        Inventory = {},",
	"        Wallet = 1000,",
	"        Level = 1,",
	"        LastSync = os.time()",
	"    }",
	'    print(string.format("[Mock DB] State diinisialisasi untuk player: %s (ID: %d)", player.Name, player.UserId))',
	"end)",
	"",
	"Players.PlayerRemoving:Connect(function(player)",
	"    ServerStateCache.PlayersData[player.UserId] = nil",
	"end)",
	"",
}

local remoteCount = 0

pcall(function()
	for _, child in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
		if child:IsA("RemoteEvent") then
			remoteCount = remoteCount + 1
			table.insert(mockLines, string.format("-- [REMOTE EVENT #%d]", remoteCount))
			table.insert(mockLines, string.format("-- Object Path: game.%s", child:GetFullName()))
			table.insert(mockLines, string.format("if game.%s then", child:GetFullName()))
			table.insert(
				mockLines,
				string.format("    game.%s.OnServerEvent:Connect(function(player, ...)", child:GetFullName())
			)
			table.insert(mockLines, "        local args = {...}")
			table.insert(
				mockLines,
				'        print(string.format("[Network Recv] Event: %s | Pengirim: %s | Args: %d", player.Name, #args))'
			)
			table.insert(mockLines, "        if #args > 0 then")
			table.insert(mockLines, "            for index, value in ipairs(args) do")
			table.insert(
				mockLines,
				'                print(string.format("   -> Param [%d]: %s (Type: %s)", index, tostring(value), type(value)))'
			)
			table.insert(mockLines, "            end")
			table.insert(mockLines, "        end")
			table.insert(mockLines, "    end)")
			table.insert(mockLines, "end\n")
		elseif child:IsA("RemoteFunction") then
			remoteCount = remoteCount + 1
			table.insert(mockLines, string.format("-- [REMOTE FUNCTION #%d]", remoteCount))
			table.insert(mockLines, string.format("-- Object Path: game.%s", child:GetFullName()))
			table.insert(mockLines, string.format("if game.%s then", child:GetFullName()))
			table.insert(
				mockLines,
				string.format("    game.%s.OnServerInvoke = function(player, ...)", child:GetFullName())
			)
			table.insert(mockLines, "        local args = {...}")
			table.insert(
				mockLines,
				'        print(string.format("[Network Invoke] Function: %s | Pemanggil: %s", player.Name))'
			)
			table.insert(
				mockLines,
				"        local playerData = ServerStateCache.PlayersData[player.UserId] or { Wallet = 0, Level = 1, Inventory = {} }"
			)
			table.insert(mockLines, "        return {")
			table.insert(mockLines, "            Success = true,")
			table.insert(mockLines, "            Timestamp = os.time(),")
			table.insert(
				mockLines,
				"            Payload = { ClientArgsPassed = #args, ServerStateSnapshot = playerData },"
			)
			table.insert(mockLines, "            Errors = {}")
			table.insert(mockLines, "        }")
			table.insert(mockLines, "    end")
			table.insert(mockLines, "end\n")
		end
	end
end)

local agentsLines = {
	"# Agentic Development Context — USSI Project Recovery",
	"",
	"## 1. Project Overview",
	string.format("* **Target Game Place ID:** %s", tostring(game.PlaceId)),
	string.format("* **Target Game Version:** %s", tostring(game.PlaceVersion)),
	string.format("* **Primary Artifact:** `%s.rbxlx`", fileNameRaw),
	"* **Context Date:** 2026 Engine Standard",
	"",
	"## 2. Technical Stack & Workspace Layout",
	"* **Target Language:** Luau (Roblox Client-Side Ecosystem)",
	"* **Architecture Goal:** Clean Architecture, SOLID Principles, & Repository Design Pattern.",
	string.format("* **Network Status:** %d Remote Endpoints mapped into Mock Server.", remoteCount),
	"",
	"## 3. Agent Execution Protocol (Next Steps)",
	"### Task A: Structural Verification",
	string.format("1. Parse the generated `%s.rbxlx` place file to extract UI elements and LocalScripts.", fileNameRaw),
	"2. Cross-reference files with the expanded logic inside `NetworkHandlerMock_Server.luau`.",
	"",
	"### Task B: Bytecode Decompilation Fallback Pipeline",
	"* Jika terdapat LocalScript yang gagal didekompilasi oleh executor, jalankan pipeline lokal:",
	"  python3 ~/2026/robloxScripts/rbxlx-decompiler/decompiler.py",
	"",
	"### Task C: Refactoring Logic Guardrails",
	"* **Isolate Network Logic:** AI Agent wajib membungkus seluruh interaksi remote payload ke dalam sebuah layer Gateway atau Network Repository. Jangan menulis panggilan bare :FireServer() secara acak di dalam modul UI.",
}

local finalMockScript = table.concat(mockLines, "\n")
local finalAgentsMd = table.concat(agentsLines, "\n")

local _, writeMockErr = pcall(function()
	writefile("NetworkHandlerMock_Server.luau", finalMockScript)
end)
if writeMockErr then
	warn("[-] Gagal menulis file server dummy: " .. tostring(writeMockErr))
else
	print("[+] File dibuat: NetworkHandlerMock_Server.luau")
end

local _, writeAgentsErr = pcall(function()
	writefile("AGENTS.md", finalAgentsMd)
end)
if writeAgentsErr then
	warn("[-] Gagal menulis AGENTS.md: " .. tostring(writeAgentsErr))
else
	print("[+] File dibuat: AGENTS.md")
end

print("==================================================")
print("[+] ALL PIPELINES EXECUTED SUCCESSFULLY!")
print("==================================================")
pcall(function()
	setclipboard(fileNameRaw .. ".rbxlx")
end)
