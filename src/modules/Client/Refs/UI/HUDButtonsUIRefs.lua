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
local WheelUIRefs = {}

type ModuleData = {
    Right: Frame,
    HUDButtonsUI: Frame,
    Gifts: ImageButton,
    Troll: ImageButton,
    Wheel: ImageButton,

    _Promise: Promise.Promise<any>,
}
export type Module = typeof(WheelUIRefs) & ModuleData

WheelUIRefs._Promise = Promise.new()

-- [ Private Functions ] --

-- [ Public Functions ] --
function WheelUIRefs.Start(self: Module)
    self.Right = UIRefs.HUD:WaitForChild("Right") :: Frame
    self.HUDButtonsUI = self.Right:WaitForChild("HUDButtonsUI") :: Frame
    self.Gifts = self.HUDButtonsUI:WaitForChild("Gifts") :: ImageButton
    self.Troll = self.HUDButtonsUI:WaitForChild("Troll") :: ImageButton
    self.Wheel = self.HUDButtonsUI:WaitForChild("Wheel") :: ImageButton

    self._Promise:Resolve()
end

function WheelUIRefs.WhenReady(self: Module)
    return self._Promise
end

return WheelUIRefs :: Module