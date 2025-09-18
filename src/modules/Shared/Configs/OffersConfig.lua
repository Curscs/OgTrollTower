--[=[
    @class OfferConfig
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local OffersConfig = {}

-- [ Types ] --

export type Module = typeof(OffersConfig)

OffersConfig._Offers = {
    ["1"] = {
        ["1"] = {
            Name = "Rainbow Carpet",
            Type = "Item",
            ProductID = "",
            Image = "",
        },

        ["2"] = {
            Name = "HD Admin",
            Type = "HD Admin",
            ProductID = "",
            Image = "",
        },

        ["3"] = {
            Name = "Alpha Male Slap",
            Type = "Item",
            ProductID = "",
            Image = "",

        },

        ["4"] = {
            Name = "OP Coil",
            Type = "HD Admin",
            ProductID = "",
            Image = "",
        }
    },

    ["2"] = {
        ["1"] = {
            Name = "Blue Laser Gun",
            Type = "Item",
            ProductID = "",
            Image = "",
        },

        ["2"] = {
            Name = "Giant Slap Hand",
            Type = "Item",
            ProductID = "",
            Image = "",
        },

        ["3"] = {
            Name = "Flying Cloud",
            Type = "Item",
            ProductID = "",
            Image = "",

        },

        ["4"] = {
            Name = "Invisible Cape",
            Type = "Item",
            ProductID = "",
            Image = "",
        }
    }
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function OffersConfig.GetVar(self: Module, offerNum: string): any
    local data = self._Offers[offerNum]
    local value = data

    if value == nil then
        error("Offer number '" .. tostring(offerNum) .. "' not found in OffersConfig")
    end

    return value
end

return OffersConfig :: Module