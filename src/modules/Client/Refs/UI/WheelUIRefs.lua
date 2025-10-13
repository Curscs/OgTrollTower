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
    SpinText: TextLabel,
    Close: ImageButton,
    PurchaseButtons: Frame,
    Buy1Spin: ImageButton,
    Buy3Spins: ImageButton,
    Buy10Spins: ImageButton,
    

    _Promise: Promise.Promise<any>,
}
export type Module = typeof(WheelUIRefs) & ModuleData

WheelUIRefs._Promise = Promise.new()

-- [ Private Functions ] --

-- [ Public Functions ] --
function WheelUIRefs.Start(self: Module)
    UIRefs:WhenReady()
    self.WheelUI = UIRefs.Main:WaitForChild("WheelUI") :: Frame
    self.Wheel = self.WheelUI:WaitForChild("Wheel") :: ImageLabel
    self.Elements = self.Wheel:WaitForChild("Elements") :: Folder
    self.Pointer = self.WheelUI:WaitForChild("Pointer") :: ImageLabel
    self.Spin = self.WheelUI:WaitForChild("Spin") :: ImageButton
    self.SpinText = self.Spin:WaitForChild("SpinText") :: TextLabel
    self.Close = self.WheelUI:WaitForChild("Close") :: ImageButton
    self.PurchaseButtons = self.WheelUI:WaitForChild("PurchaseButtons") :: Frame
    self.Buy1Spin = self.PurchaseButtons:WaitForChild("Buy1Spin") :: ImageButton
    self.Buy3Spins = self.PurchaseButtons:WaitForChild("Buy3Spins") :: ImageButton
    self.Buy10Spins = self.PurchaseButtons:WaitForChild("Buy10Spins") :: ImageButton

    self._Promise:Resolve()
end

function WheelUIRefs.WhenReady(self: Module)
    return self._Promise
end

return WheelUIRefs :: Module