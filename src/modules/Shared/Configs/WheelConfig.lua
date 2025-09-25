--[=[
    @class WheelConfig
]=]
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WheelConfig = {
    Rewards = {
        ["3000 Coins"] = {
            Slot = 1,
            Chance = 25,
            RewardType = "Currency",
            Image = "rbxassetid://76727815183468"
        },
        ["Rainbow Carpet"] = {
            Slot = 2,
            Chance = 0.9,
            RewardType = "Item",
            Image = "rbxassetid://130845798089713",
        },
        ["1000 Coins"] = {
            Slot = 3,
            Chance = 36,
            RewardType = "Currency",
            Image = "rbxassetid://76727815183468"
        },
        ["OP Coil"] = {
            Slot = 4,
            Chance = 18,
            RewardType = "Item",
            Image = "rbxassetid://132794750806317"
        },
        ["God Slap"] = {
            Slot = 5,
            Chance = 6,
            RewardType = "Item",
            Image = "rbxassetid://105078718716725"
        },
        ["Grapple Hook"] = {
            Slot = 6,
            Chance = 8,
            RewardType = "Item",
            Image = "rbxassetid://132957916234592"
        },
        ["Error Slap"] = {
            Slot = 7,
            Chance = 6,
            RewardType = "Item",
            Image = "rbxassetid://105078718716725"
        },
        ["HD Admin"] = {
            Slot = 8,
            Chance = 0.1,
            RewardType = "HD Admin",
            Image = "rbxassetid://78038723830407"
        },
    },
    FreeSpinCooldown = 10
}

-- [ Types ] --
export type Module = typeof(WheelConfig)

return WheelConfig :: Module