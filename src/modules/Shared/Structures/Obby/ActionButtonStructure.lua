-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type ActionButtonStructure = {
    Upper: Part,
    Lower: Part
}

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ActionButtonStructure = function(TrollButton: Model)
    local Upper = TrollButton:WaitForChild("Upper", 5)
    local Lower = TrollButton:WaitForChild("Lower", 5)
    
    return {
        Upper = Upper,
        Lower = Lower,
    } :: ActionButtonStructure
end

export type Module = typeof(ActionButtonStructure)

-- [ Private Functions ] --

-- [ Public Functions ] --

return ActionButtonStructure :: Module