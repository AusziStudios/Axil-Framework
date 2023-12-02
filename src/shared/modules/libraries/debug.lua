local originalDebug = debug

local debug = {}

local lastCheckpoint = nil
function debug.checkpoint(name)
	local newClock = os.clock()
	local change = newClock - (lastCheckpoint or newClock)
	warn("Checkpoint", change, name)
	lastCheckpoint = newClock
end

setmetatable(debug, {
	__index = originalDebug
})

return debug