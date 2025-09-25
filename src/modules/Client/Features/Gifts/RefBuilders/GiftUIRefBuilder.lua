--[=[
    @class GiftUIStructure
]=]
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type Structure = {
	Back: ImageLabel,
	BackGradient: UIGradient,
	Front: ImageLabel,
	FrontGradient: UIGradient,
	Icon: ImageLabel,
	Texture: ImageLabel,
	GiftName: TextLabel,
	GiftTime: TextLabel,
}

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GiftUIStructure = function(GiftUI: Instance)
	local Back = GiftUI:WaitForChild("Back", 5) :: ImageLabel
	local BackGradient = Back:WaitForChild("UIGradient", 5) :: UIGradient
	local Front = GiftUI:WaitForChild("Front", 5) :: ImageLabel
	local FrontGradient = Front:WaitForChild("UIGradient") :: UIGradient
	local Icon = GiftUI:WaitForChild("Icon", 5) :: ImageLabel
	local Texture = GiftUI:WaitForChild("Texture", 5) :: ImageLabel
	local GiftName = GiftUI:WaitForChild("GiftName", 5) :: TextLabel
	local GiftTime = GiftUI:WaitForChild("GiftTime", 5) :: TextLabel

	return {
		Back = Back,
		BackGradient = BackGradient,
		Front = Front,
		FrontGradient = FrontGradient,
		Icon = Icon,
		Texture = Texture,
		GiftName = GiftName,
		GiftTime = GiftTime,
	} :: Structure
end

export type Module = typeof(GiftUIStructure)

-- [ Private Functions ] --

-- [ Public Functions ] --

return GiftUIStructure :: Module