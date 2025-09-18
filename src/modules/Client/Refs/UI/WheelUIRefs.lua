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
    WheelUI: Frame,
    Wheel: ImageLabel,
    Elements: Folder,
    Pointer: ImageLabel,
    Spin: ImageButton,
    Close: ImageButton,

    _Promise: Promise.Promise<any>,
}
export type Module = typeof(WheelUIRefs) & ModuleData

WheelUIRefs._Promise = Promise.new()

-- [ Private Functions ] --

-- [ Public Functions ] --
function WheelUIRefs.Start(self: Module)
    self.WheelUI = UIRefs.Main:WaitForChild("WheelUI") :: Frame
    self.Wheel = self.WheelUI:WaitForChild("Wheel") :: ImageLabel
    self.Elements = self.Wheel:WaitForChild("Elements") :: Folder
    self.Pointer = self.WheelUI:WaitForChild("Pointer") :: ImageLabel
    self.Spin = self.WheelUI:WaitForChild("Spin") :: ImageButton
    self.Close = self.WheelUI:WaitForChild("Close") :: ImageButton

    self._Promise:Resolve()
end

function WheelUIRefs.WhenReady(self: Module)
    return self._Promise
end

return WheelUIRefs :: Module