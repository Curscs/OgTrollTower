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

export type Diff = {
    Seq: number,
    Added: {},
    Updated: {},
    Removed: {},
}

export type ObjectData<T> = {
    _Data: { [string]: T },
    _Seq: number,
    Changed: Signal.Signal<{ [string]: T }, number>
}
export type Object<T> = ObjectData<T> & Module
export type Module = typeof(MapCache)

-- [ Private Functions ] --

-- [ Public Functions ] --
function MapCache.new<T>(diff: Diff?): Object<T>
    local self = setmetatable({} :: any, MapCache) :: Object<T>

    self._Data = {}
    self._Seq = 0
    self.Changed = Signal.new() :: any

    if diff then
        self:ApplyDiff(diff)
    end
    
    return self
end

function MapCache.GetAll<T>(self: Object<T>): { [string]: T }
    return self._Data
end

function MapCache.Get<T>(self: Object<T>, id: string): T?
    return self._Data[id]
end

function MapCache.ApplyDiff<T>(self: Object<T>, diff: Diff)
    local Added, Updated, Removed = diff.Added or {}, diff.Updated or {}, diff.Removed or {}

    if diff.Seq ~= nil and diff.Seq <= self._Seq then
        warn(("[MapCache] Stale diff: have %d, got %d"):format(self._Seq, diff.Seq))
        return
    end

    for k, v in pairs(Added) do
        if self._Data[k] then
            warn("MapCache: Attempted to add existing key '%s'. Existing value: %s, New value: %s", k, self._Data[k], v)
            continue
        end

        self._Data[k] = v
    end

    for k, v in pairs(Updated) do
        if not self._Data[k] then
            warn("MapCache: Attempted to change non-existent key '%s'. New value: %s", k, v)
            continue
        end

        self._Data[k] = v
    end

    for k, v in pairs(Removed) do
        if not self._Data[k] then
            warn("MapCache: Attempted to change non-existent key '%s'. New value: %s", k, v)
            continue
        end

        self._Data[k] = nil
    end

    self._Seq = diff.Seq
    self.Changed:Fire(self._Data, self._Seq)
end

return MapCache