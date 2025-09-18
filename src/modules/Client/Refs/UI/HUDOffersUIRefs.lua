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
local HUDOffersUIRefs = {}

type ModuleData = {
    Left: Frame,
    HUDOffersUI: Frame,
    Offer1: Frame,
    Offer2: Frame,

    _Promise: Promise.Promise<any>,
}
export type Module = typeof(HUDOffersUIRefs) & ModuleData

HUDOffersUIRefs._Promise = Promise.new()

-- [ Private Functions ] --

-- [ Public Functions ] --
function HUDOffersUIRefs.Start(self: Module)
    self.Left = UIRefs.HUD:WaitForChild("Left") :: Frame
    self.HUDOffersUI = self.Left:WaitForChild("HUDOffersUI") :: Frame
    self.Offer1 = self.HUDOffersUI:WaitForChild("1") :: Frame
    self.Offer2 = self.HUDOffersUI:WaitForChild("2") :: Frame

    self._Promise:Resolve()
end

function HUDOffersUIRefs.WhenReady(self: Module)
    return self._Promise
end

return HUDOffersUIRefs :: Module
