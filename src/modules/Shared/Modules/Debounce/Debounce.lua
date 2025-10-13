--[=[
    @class Debounce
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local Debounce = {}
Debounce.__index = Debounce

-- [ Types ] --

export type ObjectData = {
    LastDebounce: number
}
export type Object = ObjectData & Module
export type Module = typeof(Debounce)

-- [ Private Functions ] --

-- [ Public Functions ] --
function Debounce.new(debounceAmount: number): Object
    local self = setmetatable({} :: any, Debounce) :: Object
    
    self.LastDebounce = 0

    return self
end

function Debounce.Try(self: Object, cb: () -> ())
    if self.LastDebounce == 0 or self.LastDebounce < os.clock() then
        cb()
    end
end

return Debounce