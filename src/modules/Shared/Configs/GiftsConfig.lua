--[=[
    @class GiftsConfig
]=]
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GiftsConfig = {
    MaxGifts = 12,
    Gifts = {
        ["1"] = {
            Name = "300 Coins",
            Type = "Currency", -- types: { Currency, Item }
            Time = 140,
    
            FrontGradient = ColorSequence.new(Color3.fromRGB(255, 198, 65)),
            BackGradient = ColorSequence.new(Color3.fromRGB(145, 105, 19)),
            Image = ""
        },
        ["2"] = {
            Name = "Speed Coil",
            Type = "Item",
            Time = 240,
    
            FrontGradient = ColorSequence.new(Color3.fromRGB(255, 198, 65)),
            BackGradient = ColorSequence.new(Color3.fromRGB(145, 105, 19)),
            Image = ""
        },
        ["3"] = {
            Name = "Heal Coil",
            Type = "Currency",
            Time = 480,
    
            FrontGradient = ColorSequence.new(Color3.fromRGB(255, 198, 65)),
            BackGradient = ColorSequence.new(Color3.fromRGB(145, 105, 19)),
            Image = ""
        },
        ["4"] = {
			Name = "Gravity Coil",
            Type = "Item",
            Time = 600,
    
            FrontGradient = ColorSequence.new(Color3.fromRGB(255, 198, 65)),
            BackGradient = ColorSequence.new(Color3.fromRGB(145, 105, 19)),
            Image = ""
        },
        ["5"] = {
			Name = "5500 Coins",
            Type = "Currency",
            Time = 840,
    
            FrontGradient = ColorSequence.new(Color3.fromRGB(255, 198, 65)),
            BackGradient = ColorSequence.new(Color3.fromRGB(145, 105, 19)),
            Image = ""
        },
        ["6"] = {
			Name = "Grapple Hook",
            Type = "Item",
            Time = 1100,
    
            FrontGradient = ColorSequence.new(Color3.fromRGB(255, 198, 65)),
            BackGradient = ColorSequence.new(Color3.fromRGB(145, 105, 19)),
            Image = ""
        },
        ["7"] = {
			Name = "Invisibility Cape",
            Type = "Item",
            Time = 1300,
    
            FrontGradient = ColorSequence.new(Color3.fromRGB(255, 198, 65)),
            BackGradient = ColorSequence.new(Color3.fromRGB(145, 105, 19)),
            Image = ""
        },
        ["8"] = {
			Name = "Rainbow Carpet",
            Type = "Item",
            Time = 1800,
    
            FrontGradient = ColorSequence.new(Color3.fromRGB(255, 198, 65)),
            BackGradient = ColorSequence.new(Color3.fromRGB(145, 105, 19)),
            Image = ""
        },
    }
} :: GiftData

-- [ Types ] --
export type GiftData = {
    MaxGifts: number,
    Gifts: {
        [string]: {
            Name: string,
            Type: string,
            Time: number,
            FrontGradient: ColorSequence,
            BackGradient: ColorSequence,
            Image: string,
        }
    }
}

export type Module = typeof(GiftsConfig)

return GiftsConfig :: Module