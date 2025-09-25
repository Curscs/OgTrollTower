-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type Structure = {
    Upper: Part,
    Lower: Part
}

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ActionButtonRefBuilder = function(TrollButton: Model)
    local Upper = TrollButton:WaitForChild("Upper", 5)
    local Lower = TrollButton:WaitForChild("Lower", 5)
    
    return {
        Upper = Upper,
        Lower = Lower,
    } :: Structure
end

export type Module = typeof(ActionButtonRefBuilder)

-- [ Private Functions ] --

-- [ Public Functions ] --

return ActionButtonRefBuilder :: Module