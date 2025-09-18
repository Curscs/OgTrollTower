--[=[
    @class DamageService
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")
-- [ Constants ] --

-- [ Variables ] --
local _Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "DamageService")

-- [ Module Table ] --
local DamageService = {}

-- [ Types ] --

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(DamageService) & ModuleData

-- [ Private Functions ] --
function DamageService.DamagePlayer(self: Module, player: Player, amount: number): boolean
    if not player or not player:IsDescendantOf(Players) then
        return false
    end

    if typeof(amount) ~= "number" or amount <= 0 then
        return false
    end

    local Char = player.Character

    if not Char then
        return false
    end

    local Humanoid = Char:FindFirstChildOfClass("Humanoid")

    if not Humanoid or Humanoid.Health <= 0 then
        return false
    end

    Humanoid.Health = math.max(0, Humanoid.Health - amount)

    return true
end

-- [ Public Functions ] --
function DamageService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function DamageService.Start(self: Module)

end

return DamageService :: Module