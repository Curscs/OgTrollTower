-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type Structure = {
    Zone: BasePart,
}

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolGiverRefBuilder = function(ToolGiver: Model)
    local Zone = ToolGiver:WaitForChild("Zone", 5)
    
    return {
        Zone = Zone,
    } :: Structure
end

export type Module = typeof(ToolGiverRefBuilder)

-- [ Private Functions ] --

-- [ Public Functions ] --

return ToolGiverRefBuilder :: Module