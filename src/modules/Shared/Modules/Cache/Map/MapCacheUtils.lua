--[=[
    @class MapCache
]=]
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MapCache = {}

-- [ Types ] --
export type Module = typeof(MapCache)

-- [ Private Functions ] --

-- [ Public Functions ] --
function MapCache.CreateDiff(self: Module, seq: number?, added: {}?, updated: {}?, removed: {}?)
    local Diff = {
        Added = added or {},
        Updated = updated or {},
        Removed = removed or {},
    }

    return Diff
end

return MapCache :: Module