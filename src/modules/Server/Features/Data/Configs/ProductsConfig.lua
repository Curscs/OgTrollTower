--[=[
    @class ProductConfig
]=]
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ProductConfig = {
    ["3419408958"] = {
        Type = "Wheel",
        Spins = 1
    },
    ["3422365091"] = {
        Type = "Wheel",
        Spins = 3
    },
    ["3422365088"] = {
        Type = "Wheel",
        Spins = 10
    },

} :: { [ProductID]: ProductData }

-- [ Types ] --
type ProductID = string

type CurrencyData = {
    Type: "Currency",
    CurrencyName: string,
    CurrencyAmount: number,
}

type WheelData = {
    Type: "Wheel",
    Spins: number,
}

type ToolData = {
    Type: "Tool",
    ToolName: string,
}

type Custom = {
    Type: "Custom",
    Func: (profile: any) -> (),
}

type ProductData = CurrencyData | WheelData | ToolData | Custom

export type Module = typeof(ProductConfig)

-- [ Private Functions ] --

-- [ Public Functions ] --

return ProductConfig :: Module