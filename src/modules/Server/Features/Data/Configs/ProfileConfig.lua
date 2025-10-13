--[=[
    @class ProfileConfig
]=]
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ProfileConfig = {
    Template = {
        Coins = 0,
        Tools = {
            ["Gravity Coil"] = true
        },
        Wheel = {
            Spins = 0,
            NextFreeSpin = 0,
        },
        PurchaseIdCache = {}
    },

    Leaderstats = {"Coins"}
}

-- [ Types ] --
export type ProfileData = {
    ["Coins"]: number,
    ["Tools"]: {},
    ["Wheel"]: {
        ["Spins"]: number,
        ["NextFreeSpin"]: number,
    },
    ["PurchaseIdCache"]: {}
}

export type Module = typeof(ProfileConfig)

-- [ Private Functions ] --

-- [ Public Functions ] --

return ProfileConfig :: Module