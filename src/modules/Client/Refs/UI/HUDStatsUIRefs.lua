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
local HUDStatsUIRefs = {}

type ModuleData = {
    Right: Frame,
    HUDStatsUI: Frame,

    _Promise: Promise.Promise<any>,
}
export type Module = typeof(HUDStatsUIRefs) & ModuleData

HUDStatsUIRefs._Promise = Promise.new()

-- [ Private Functions ] --

-- [ Public Functions ] --
function HUDStatsUIRefs.Start(self: Module)
    UIRefs:WhenReady()
    self.Right = UIRefs.HUD:WaitForChild("Right") :: Frame
    self.HUDStatsUI = self.Right:WaitForChild("HUDStatsUI") :: Frame

    self._Promise:Resolve()
end

function HUDStatsUIRefs.WhenReady(self: Module)
    return self._Promise
end

return HUDStatsUIRefs :: Module