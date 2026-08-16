# 📦 Universal Syn Save Instance (USSI)

> **© 2026 Luau / ZypherDev / MSayib** — The premier in-engine place and model serialization engine for Roblox & Luau environments.
> High-fidelity instance hierarchy dumping, executable bytecode extraction, and XML metadata preservation.

---

## 📖 Overview

**Universal Syn Save Instance (USSI)** is an advanced, robust in-engine dumper designed to serialize Roblox instances, game hierarchies, and executable script bytecodes into standard Roblox `.rbxlx` (place) and `.rbxmx` (model) files.

### 🌟 Key Capabilities
- **Non-Destructive Serialization**: Captures game hierarchies without mutating the client-side game state or interrupting physics.
- **Embedded Bytecode Extraction (`SaveBytecode = true`)**: Extracts raw executable bytecode blobs from `LocalScript` and `ModuleScript` instances, encoding them cleanly inside the `Source` XML property for offline decompilation with Zypher.
- **Provenance XML Metadata**: Automatically stamps `<Meta name="ClientVersion">`, `<Meta name="PlaceId">`, and `<Meta name="PlaceVersion">` directly into the `.rbxlx` file header.
- **Modern Luau Engine Compatibility**: Compatible with Roblox Studio 0.734+ and modern executor environments with optimized buffer handling and Base64 routines.
- **Granular Isolation Options**: Easily isolate `StarterPlayer`, `LocalPlayer`, character models, or nil instances.

---

## 🚀 Quickstart & In-Engine Execution

### 1. Basic Loadstring Usage
Run the following script in your executor or script execution environment:

```luau
local Params = {
    RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
    SSI = "saveinstance",
}

local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

-- Execute with default options
synsaveinstance({})
```

### 2. Full Bytecode & Provenance Capture Configuration
To generate place dumps optimized for the **Zypher Decompiler Suite**:

```luau
local synsaveinstance = loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.luau", true), "saveinstance")()

local Options = {
    -- Core saving options
    Mode = "full",                 -- "full", "optimized", or "scripts"
    FilePath = "Place_Dump",       -- Output filename (saved to workspace folder)
    
    -- Bytecode & Decompilation
    SaveBytecode = true,           -- Embed raw binary bytecode into <ProtectedString name="Source">
    Decompile = false,             -- Set false to defer lifting to offline Zypher decompiler
    
    -- Hierarchy Filtering
    IsolateStarterPlayer = true,   -- Isolate StarterPlayerScripts / StarterCharacterScripts
    IsolateLocalPlayer = true,     -- Isolate LocalPlayer data
    NilInstances = false,          -- Save nil instances if executor supports getnilinstances()
    IgnoreDefaultProps = true,     -- Omit default properties to keep file size compact
    
    -- Status Notifications
    ShowStatus = true,             -- Print progress in developer console
}

synsaveinstance(Options)
```

---

## ⚙️ Configuration Options Reference

| Option | Type | Default | Description |
|---|---|---|---|
| `Mode` | `string` | `"full"` | Saving mode (`"full"`, `"optimized"`, `"scripts"`, or `"custom"`). |
| `FilePath` | `string` | Auto | Output filename without extension (e.g. `"Dump_2026"`). |
| `SaveBytecode` | `boolean` | `true` | Embed Base64-encoded raw bytecode for offline decompilation. |
| `Decompile` | `boolean` | `false` | Run in-engine decompiler (recommended `false` when using Zypher). |
| `IsolateStarterPlayer` | `boolean` | `true` | Group StarterPlayer scripts into an isolated folder. |
| `IsolateLocalPlayer` | `boolean` | `false` | Serialize the client's LocalPlayer container. |
| `NilInstances` | `boolean` | `false` | Capture unparented instances via `getnilinstances()`. |
| `IgnoreList` | `table` | `{}` | Array of instances or class names to exclude from serialization. |
| `SafeMode` | `boolean` | `true` | Enhanced error handling during instance property queries. |

---

## 🤖 Instructions for AI Agents & Automation

For automated script execution or test pipelines:

1. **Deterministic Output Location**: Dumps are written using the executor's `writefile()` function directly into the executor's `workspace/` folder.
2. **Bytecode Structure**:
   Bytecodes are formatted as:
   ```xml
   <ProtectedString name="Source">--[[
   -- Bytecode (Base64):
   -- LHV...
   --]]</ProtectedString>
   ```
3. **Metadata Verification**:
   Verify that output `.rbxlx` files contain `<Meta name="ClientVersion">` and `<Meta name="PlaceId">` in the root header before passing them to `zypher-decompiler` / `scripts/zy_lab.py`.

---

## 📜 Credits & License

- **Authors**: UniversalSynSaveInstance Team & MSayib / ZypherDev
- **Repository**: [`MSayib/UniversalSynSaveInstance`](https://github.com/MSayib/UniversalSynSaveInstance) (Fork & In-Engine Zypher Probe integration).
- **License**: Provided under the terms in the [LICENSE](LICENSE) file.
