--!strict
local Probe = require("./probe")

local count = 0
for name, source in pairs(Probe.Sources) do
    count += 1
    assert(type(name) == "string" and #name > 0, "Invalid name")
    assert(type(source) == "string" and #source > 0, "Invalid source")
end

print(string.format("All %d probe sources verified successfully!", count))
assert(count == 17, string.format("Expected 17 probe sources, got %d", count))
