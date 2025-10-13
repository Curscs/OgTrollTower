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
local HUDButtonsUIRefs = {}

type ModuleData = {
    Right: Frame,
    HUDButtonsUI: Frame,
    Gifts: ImageButton,
    Troll: ImageButton,
    Wheel: ImageButton,

    _Promise: Promise.Promise<any>,
}
export type Module = typeof(HUDButtonsUIRefs) & ModuleData

HUDButtonsUIRefs._Promise = Promise.new()

-- [ Private Functions ] --

-- [ Public Functions ] --
function HUDButtonsUIRefs.Start(self: Module)
    UIRefs:WhenReady()
    self.Right = UIRefs.HUD:WaitForChild("Right") :: Frame
    self.HUDButtonsUI = self.Right:WaitForChild("HUDButtonsUI") :: Frame
    self.Gifts = self.HUDButtonsUI:WaitForChild("Gifts") :: ImageButton
    self.Troll = self.HUDButtonsUI:WaitForChild("Troll") :: ImageButton
    self.Wheel = self.HUDButtonsUI:WaitForChild("Wheel") :: ImageButton

    self._Promise:Resolve()
end

function HUDButtonsUIRefs.WhenReady(self: Module)
    return self._Promise
end

return HUDButtonsUIRefs :: Module