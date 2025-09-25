--[=[
    @class StateManager
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local StateManager = {}
StateManager.__index = StateManager

-- [ Types ] --
export type ObjectData<T> = {
    ChangeSignal: Signal.Signal<any>,
    _Cache: T,
}
export type Object<T> = ObjectData<T> & Module
export type Module = typeof(StateManager)

-- [ Private Functions ] --

-- [ Public Functions ] --
function StateManager.new<T>(initData: T): Object<T>
    local self = setmetatable({} :: any, StateManager) :: Object<T>

    self.ChangeSignal = Signal.new()
    self._Cache = initData

    return self
end

function StateManager.SetData<T>(self: Object<T>, path: { any }, value: any, hardSet: boolean): boolean

end

function StateManager.GetData<T>(self: Object<T>, path: { any }): (boolean, any)
    
end

return StateManager