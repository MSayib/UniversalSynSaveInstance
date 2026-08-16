--!strict
-- Zypher In-Engine HTTP Client Bridge (Roblox Studio & Executor)
-- Connects in-engine runtime scripts directly to local Zypher decompiler server
-- (c) 2026 ZypherDev / MSayib

local HttpService = game:GetService("HttpService")

local Zypher = {}
Zypher.BaseUrl = "http://127.0.0.1:8000"

local function getRequestFunc()
    if type(syn) == "table" and type(syn.request) == "function" then
        return syn.request
    elseif type(http_request) == "function" then
        return http_request
    elseif type(request) == "function" then
        return request
    end
    return nil
end

--- Health check to verify local Zypher server is running
function Zypher.CheckHealth(): (boolean, string?)
    local req = getRequestFunc()
    if req then
        local res = req({
            Url = Zypher.BaseUrl .. "/health",
            Method = "GET",
        })
        if res and res.StatusCode == 200 then
            return true, res.Body
        end
        return false, res and res.StatusMessage or "Server unreachable"
    else
        local ok, body = pcall(function()
            return HttpService:GetAsync(Zypher.BaseUrl .. "/health")
        end)
        return ok, ok and body or "HttpService error: " .. tostring(body)
    end
end

--- Decompile bytecode directly through local Zypher server
function Zypher.Decompile(bytecodeOrBase64: string): (boolean, string)
    local payload = HttpService:JSONEncode({
        bytecode = bytecodeOrBase64,
    })

    local req = getRequestFunc()
    if req then
        local res = req({
            Url = Zypher.BaseUrl .. "/decompile",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
            },
            Body = payload,
        })
        if res and res.StatusCode == 200 then
            local data = HttpService:JSONDecode(res.Body)
            if data.success and data.source then
                return true, data.source
            end
            return false, data.error or "Decompilation failed"
        end
        return false, "HTTP " .. tostring(res and res.StatusCode) .. ": " .. tostring(res and res.Body)
    else
        local ok, resp = pcall(function()
            return HttpService:PostAsync(
                Zypher.BaseUrl .. "/decompile",
                payload,
                Enum.HttpContentType.ApplicationJson
            )
        end)
        if ok and resp then
            local data = HttpService:JSONDecode(resp)
            if data.success and data.source then
                return true, data.source
            end
            return false, data.error or "Decompilation failed"
        end
        return false, "HttpService request failed: " .. tostring(resp)
    end
end

return Zypher
