-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type Structure = {
    Texture: Texture,
}

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PushPartStructure = function(TrollButton: BasePart)
    local Texture = TrollButton:WaitForChild("Texture", 5)
    
    return {
        Texture = Texture,
    } :: Structure
end

export type Module = typeof(PushPartStructure)

-- [ Private Functions ] --

-- [ Public Functions ] --

return PushPartStructure :: Module