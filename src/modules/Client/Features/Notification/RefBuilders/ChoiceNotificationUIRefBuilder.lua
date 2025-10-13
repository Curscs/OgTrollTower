--[=[
    @class ChoiceNotificationUIRefBuilder
]=]
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --
export type Structure = {
	UIScale: UIScale,
	Option1: ImageButton,
	Option1Text: TextLabel,
	Option2: ImageButton,
	Option2Text: TextLabel,
	Description: TextLabel,
}

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ChoiceNotificationUIRefBuilder = function(choiceNotificationUI: Instance)
	local UIScale = choiceNotificationUI:WaitForChild("UIScale") :: UIScale
	local Option1 = choiceNotificationUI:WaitForChild("Option1") :: ImageButton
	local Option1Text = Option1:WaitForChild("Option1Text") :: TextLabel
	local Option2 = choiceNotificationUI:WaitForChild("Option2") :: ImageButton
	local Option2Text = Option2:WaitForChild("Option2Text") :: TextLabel
	local Description = choiceNotificationUI:WaitForChild("Description") :: TextLabel

	return {
		UIScale = UIScale,
		Option1 = Option1,
		Option1Text = Option1Text,
		Option2 = Option2,
		Option2Text = Option2Text,
		Description = Description,
	} :: Structure
end

export type Module = typeof(ChoiceNotificationUIRefBuilder)

-- [ Private Functions ] --

-- [ Public Functions ] --

return ChoiceNotificationUIRefBuilder :: Module