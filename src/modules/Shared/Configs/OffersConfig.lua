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
local OffersConfig = {
    ["1"] = {
        ["1"] = {
            Name = "Rainbow Carpet",
            Type = "Tool", -- types: { Currency, Tool }
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
            Type = "Tool",
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
            Type = "Tool",
            ProductID = "",
            Image = "",
        },

        ["2"] = {
            Name = "Giant Slap Hand",
            Type = "Tool",
            ProductID = "",
            Image = "",
        },

        ["3"] = {
            Name = "Flying Cloud",
            Type = "Tool",
            ProductID = "",
            Image = "",

        },

        ["4"] = {
            Name = "Invisible Cape",
            Type = "Tool",
            ProductID = "",
            Image = "",
        }
    }
}

-- [ Types ] --
export type Module = typeof(OffersConfig)

return OffersConfig :: Module