local original = math

local math = {}

setmetatable(math, {__index = original})

return math