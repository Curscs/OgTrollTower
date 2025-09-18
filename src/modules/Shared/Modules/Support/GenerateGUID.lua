-- [ Roblox Services ] --
local HttpService = game:GetService("HttpService")

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
type ID = string

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GenerateGUID = function(dataTable: { [ID]: unknown })
    local GetID = function()
        return HttpService:GenerateGUID(false)
    end

    local ID = GetID()

    while dataTable and dataTable[ID] do
        ID = GetID()
    end

    return ID
end

export type Module = typeof(GenerateGUID)

-- [ Private Functions ] --

-- [ Public Functions ] --

return GenerateGUID :: Module