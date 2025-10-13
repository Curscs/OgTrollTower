--[=[
    @class something
]=]
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local DebounceTimer = require("DebounceTimer")

-- [ Constants ] --

-- [ Variables ] --
local RateLimiter = DebounceTimer.new(0.1)

-- [ Module Table ] --
local something = function<V>(onSuccess: () -> V?): (boolean, V?)
    if RateLimiter:IsDone() then
        RateLimiter:Restart()
        return true, onSuccess()
    else
        return false
    end
end

-- [ Types ] --

export type Module = typeof(something)

-- [ Private Functions ] --

-- [ Public Functions ] --

return something :: Module