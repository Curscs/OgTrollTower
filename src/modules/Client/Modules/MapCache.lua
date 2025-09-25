--[=[
    @class MapCache
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
local MapCache = {}
MapCache.__index = MapCache

-- [ Types ] --
type Diff<T> = {

}

export type ObjectData<T> = {
    _Data: {}
}
export type Object<T> = ObjectData<T> & Module
export type Module = typeof(MapCache)

-- [ Private Functions ] --

-- [ Public Functions ] --
function MapCache.new<T>(): Object<T>
    local self = setmetatable({} :: any, MapCache) :: Object<T>

    self._Data = {}
    self._Seq = 0
    self.Changed = Signal.new()
    
    return self
end

return MapCache