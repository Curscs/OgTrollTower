-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Promise = require("Promise")
local UIRefs = require("UIRefs")

-- [ Types ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GiftsUIRefs = {}

type ModuleData = {
	GiftsUI: Frame,
	UIScale: UIScale,
	Container: Frame,
	Close: ImageButton,
	Texture: ImageLabel,
	Background: ImageLabel,

	_Promise: Promise.Promise<any>,
}
export type Module = typeof(GiftsUIRefs) & ModuleData

GiftsUIRefs._Promise = Promise.new()

-- [ Private Functions ] --

-- [ Public Functions ] --
function GiftsUIRefs.Start(self: Module)
	UIRefs:WhenReady()
	self.GiftsUI = UIRefs.Main:WaitForChild("GiftsUI") :: Frame
	self.UIScale = self.GiftsUI:WaitForChild("UIScale") :: UIScale
	self.Container = self.GiftsUI:WaitForChild("Container") :: Frame
	self.Close = self.GiftsUI:WaitForChild("Close") :: ImageButton
	self.Texture = self.GiftsUI:WaitForChild("Texture") :: ImageLabel
	self.Background = self.GiftsUI:WaitForChild("Background") :: ImageLabel

	self._Promise:Resolve()
end

function GiftsUIRefs.WhenReady(self: Module)
	return self._Promise
end

return GiftsUIRefs :: Module


