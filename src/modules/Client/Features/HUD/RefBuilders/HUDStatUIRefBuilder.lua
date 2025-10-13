--[=[
    @class HUdStatUIRefBuilder
]=]
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type Structure = {
	CurrencyAmount: TextLabel
}

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local HUDStatUIRefBuilder = function(hudStatUI: Instance)
	local CurrencyAmount = hudStatUI:WaitForChild("CurrencyAmount") :: TextLabel

	return {
		CurrencyAmount = CurrencyAmount
	} :: Structure
end

export type Module = typeof(HUDStatUIRefBuilder)

-- [ Private Functions ] --

-- [ Public Functions ] --

return HUDStatUIRefBuilder :: Module