-- [ Roblox Services ] --
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Promise = require("Promise")

-- [ Types ] --

-- [ Constants ] --

-- [ Variables ] --
local Player = Players.LocalPlayer

-- [ Module Table ] --
local WheelUIRefs = {}

type ModuleData = {
    PlayerGui: PlayerGui,
    Main: ScreenGui,
    HUD: ScreenGui,
    Notifications: ScreenGui,

    _Promise: Promise.Promise<any>,
}
export type Module = typeof(WheelUIRefs) & ModuleData

WheelUIRefs._Promise = Promise.new()

-- [ Private Functions ] --

-- [ Public Functions ] --
function WheelUIRefs.Start(self: Module)
    self.PlayerGui = Player:WaitForChild("PlayerGui") :: PlayerGui
    self.Main = self.PlayerGui:WaitForChild("Main") :: ScreenGui
    self.HUD = self.PlayerGui:WaitForChild("HUD") :: ScreenGui
    self.Notifications = self.PlayerGui:WaitForChild("Notifications") :: ScreenGui

    self._Promise:Resolve()
end

function WheelUIRefs.WhenReady(self: Module)
    return self._Promise
end

return WheelUIRefs :: Module