--[=[
    @class MapCache
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Signal = require("Signal")
local Table = require("Table")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MapCache = {}
MapCache.__index = MapCache

-- [ Types ] --

export type Diff<T> = {
    Seq: number?,
    Added: { [string]: T },
    Updated: { [string]: T },
    Removed: { [string]: T },
}

export type ObjectData<T> = {
    _Data: { [string]: T },
    _LastDiff: Diff<T>,
    _Seq: number,
    Changed: Signal.Signal<{ [string]: T }, Diff<T>, number>
}
export type Object<T> = ObjectData<T> & Module
export type Module = typeof(MapCache)

-- [ Private Functions ] --
-- [ Public Functions ] --

function MapCache.new<T>(): Object<T>
    local self = setmetatable({} :: any, MapCache) :: Object<T>

    self._Data = {}
    self._LastDiff = {
        Added = {},
        Updated = {},
        Removed = {},
    }
    self._Seq = 0
    self.Changed = Signal.new() :: any
    
    return self
end

function MapCache.Observe<T>(self: Object<T>, cb: ({[string]: T}, Diff<T>, number) -> ())
    cb(self._Data, self._LastDiff, self._Seq)

    local conn = self.Changed:Connect(cb)
    return function() conn:Disconnect() end
end

function MapCache.GetAll<T>(self: Object<T>): { [string]: T }
    return self._Data
end

function MapCache.Get<T>(self: Object<T>, id: string): T?
    return self._Data[id]
end

function MapCache.ApplyDiff<T>(self: Object<T>, diff: Diff<T>)
    if not diff.Added or not diff.Removed or not diff.Updated then
        error("[MapCache] Diff missing Added/Removed/Updated fields")
    end

    local Added, Updated, Removed = diff.Added, diff.Updated, diff.Removed

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

        if Table.deepEquivalent(v :: any, self._Data[k] :: any) then
            diff.Updated[k] = nil
            warn("MapCache: Updated value for key '%s' is equivalent to existing value. Skipping update.", k)
            continue
        end

        self._Data[k] = v
    end

    for k, v in pairs(Removed) do
        if self._Data[k] == nil then
            warn("MapCache: Attempted to change non-existent key '%s'. New value: %s", k, v)
            continue
        end

        self._Data[k] = nil
    end

    local EmptyCount = 0
    for _, v in pairs(diff) do
        if next(v) == nil then
            EmptyCount += 1
        end
    end

    

    if EmptyCount == Table.count(diff) then
        warn("[MapCache] No changes detected in diff; all diff tables are empty.")
        return
    end
    
    self._LastDiff = diff
    self._Seq = diff.Seq or self._Seq + 1
    self.Changed:Fire(self._Data, self._LastDiff, self._Seq)
end

return MapCache