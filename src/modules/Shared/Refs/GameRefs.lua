local Workspace = game:GetService("Workspace")
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local Promise = require("Promise")

-- [ Types ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GameRefs = {}

type ModuleData = {
    _Promise: Promise.Promise<any>,
    Game: Folder,
    ActionButtons: Folder,
}
export type Module = typeof(GameRefs) & ModuleData

GameRefs._Promise = Promise.new()

-- [ Private Functions ] --

-- [ Public Functions ] --
function GameRefs.Start(self: Module)
    self.Game = Workspace:WaitForChild("Game")
    self.ActionButtons = self.Game:WaitForChild("ActionButtons") :: Folder

    self._Promise:Resolve()
end

function GameRefs.WhenReady(self: Module)
    return self._Promise
end

return GameRefs :: Module