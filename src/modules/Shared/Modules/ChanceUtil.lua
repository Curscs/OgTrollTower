--[=[
    @class ChanceUtil
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --
local LUCK_AFFECTED = 5

-- [ Variables ] --

-- [ Module Table ] --
local ChanceUtil = {}
ChanceUtil.__index = ChanceUtil

-- [ Types ] --
type Chances = { [string]: number }
type Weights = Chances

export type ObjectData = {
    _InitialChances: Chances,
    _Luck: number,
    _Chances: Chances,
    _Weights: Weights,
    _TotalWeight: number,
}
export type Object = ObjectData & Module
export type Module = typeof(ChanceUtil)

-- [ Private Functions ] --
function UpdateChances(initialChances: Chances, luck: number): Chances
    local UpdatedChances = {}
    local Adjustable = {}
    local AdjustableSum = 0
    local TotalChance = 0

    for key, chance in initialChances do
        if chance <= LUCK_AFFECTED then
            local UpdatedChance = chance * luck
            UpdatedChances[key] = UpdatedChance
            TotalChance += UpdatedChance
        else
            Adjustable[key] = chance
            AdjustableSum += chance
            TotalChance += chance
        end
    end

    local Remainder = 100 - TotalChance

    for key, chance in Adjustable do
        local Ratio = chance / AdjustableSum
        local AdjustedChance = math.floor((chance + (Remainder * Ratio))*1000)/1000

        UpdatedChances[key] = AdjustedChance
    end

    return UpdatedChances
end

function UpdateWeights(chances: Chances): Weights
    local function GetDecimalCount(num: number): number
        local s = tostring(num)
        local dotIndex = string.find(s, "%.")
        if not dotIndex then return 0 end
        return #s - dotIndex
    end

    local UpdatedWeights = {}
    local TotalWeight = 0
    local Multiplier = 0 -- stores highest amount of decimals

    -- find the highest decimal
    for key, chance in chances do
        local DecimalCount = GetDecimalCount(chance)
        if Multiplier < DecimalCount then
            Multiplier = DecimalCount
        end
    end

    for key, chance in chances do
        local UpdatedWeight = chance * (10 ^ Multiplier)
        TotalWeight += UpdatedWeight
        UpdatedWeights[key] = UpdatedWeight
    end

    return UpdatedWeights
end

function GetTotalWeight(weights: Weights): number
    local TotalWeight = 0

    for key, weight in weights do
        TotalWeight += weight
    end

    return TotalWeight
end

function UpdateVariables(self: Object)
    self._Chances = UpdateChances(self._InitialChances, self._Luck)
    self._Weights = UpdateWeights(self._Chances)
    self._TotalWeight = GetTotalWeight(self._Weights)
end

-- [ Public Functions ] --
function ChanceUtil.new(chances: Chances, luck: number?): Object
    local self = setmetatable({} :: any, ChanceUtil) :: Object
    self._InitialChances = chances
    self._Luck = luck or 1
    self._Chances = UpdateChances(self._InitialChances, self._Luck)
    self._Weights = UpdateWeights(self._Chances)
    self._TotalWeight = GetTotalWeight(self._Weights)

    return self
end

function ChanceUtil.Choose(self: Object): string
    local RandomNumber = math.random(1, self._TotalWeight)
    local ProgressBar = 0

    for key, weight in self._Weights do
        ProgressBar += weight

        if RandomNumber <= ProgressBar then
            return key
        end
    end

    error("ChanceUtil.Choose: No valid choice could be made. Check weights and chances.")
end

function ChanceUtil.UpdateLuck(self: Object, value: number)
    if value < 1 then
        return
    end

    self._Luck = value
    UpdateVariables(self)
end

return ChanceUtil