--[=[
	@class DebounceUtil
	@description A utility module for managing debounced function calls to prevent rapid successive executions
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
type UserID = number
type Category = string

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DebounceUtil = {}

export type Module = typeof(DebounceUtil)

DebounceUtil._Cache = {} :: {
    UserID: {
        Category: {
            [string]: number
        }
    }
}

-- [ Private Functions ] --

-- [ Public Functions ] --

--[=[
	Attempts to execute a debounced action

	@param self Module - The DebounceUtil module
	@param name string - The name/identifier of the debounced action
	@param cooldown number - The cooldown duration in seconds
	@return boolean - Returns true if the action can be executed, false if still on cooldown
]=]
function DebounceUtil.Try(self: Module, name: string, cooldown: number)
    local Now = os.clock()
    local ExpireTime = self._Cache[name]

    if not ExpireTime or ExpireTime < Now then
        self._Cache[name] = Now + cooldown
        return true
    else
        return false
    end
end

--[=[
	Clears debounce cache entries

	@param self Module - The DebounceUtil module
	@param name string? - Optional specific action name to clear. If not provided, clears all debounce entries
]=]
function DebounceUtil.Clear(self: Module, name: string?)
    if not name then
        if self._Cache[name] then
            self._Cache[name] = {}
        end
    else
        self._Cache[name] = nil
    end
end

return DebounceUtil :: Module