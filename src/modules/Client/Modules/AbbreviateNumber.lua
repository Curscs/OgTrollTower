--[=[
    @class AbbreviateNumber
]=]
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --
local ABBREVIATIONS = {
    "K", -- 4 digits
    "M", -- 7 digits
    "B", -- 10 digits
    "T", -- 13 digits
    "QD", -- 16 digits
    "QT", -- 19 digits
    "SXT", -- 22 digits
    "SEPT", -- 25 digits
    "OCT", -- 28 digits
    "NON", -- 31 digits
    "DEC", -- 34 digits
    "UDEC", -- 37 digits
    "DDEC", -- 40 digits
}

-- [ Variables ] --

-- [ Module Table ] --
local AbbreviateNumber = function(x: number, decimals: number)
    if decimals == nil then decimals = 0 end
    local visible = nil
    local suffix = nil
    if x < 1000 then
      visible = x * math.pow(10, decimals)
      suffix = ""
    else
      local digits = math.floor(math.log10(x)) + 1
      local index = math.min(#ABBREVIATIONS, math.floor((digits - 1) / 3))
      visible = x / math.pow(10, index * 3 - decimals)
      suffix = ABBREVIATIONS[index] .. "+"
    end
    local front = visible / math.pow(10, decimals)
    local back = visible % math.pow(10, decimals)

    if decimals > 0 then
      return string.format("%i.%0." .. tostring(decimals) .. "i%s", front, back, suffix)
    else
      return string.format("%i%s", front, suffix)
    end
end

-- [ Types ] --

export type Module = typeof(AbbreviateNumber)

-- [ Private Functions ] --

-- [ Public Functions ] --

return AbbreviateNumber :: Module