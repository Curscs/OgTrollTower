--[=[
	@class InitService
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")
local GameRefs = require("GameRefs")

-- [ Types ] --

-- [ Variables ] --
local _Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "InitService")

-- [ Module Table ] --
local InitService = {}

type ModuleData = {
	_ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(InitService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function InitService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
	if self._ServiceBag ~= nil then
		error("Service already initialized")
	end
	self._ServiceBag = assert(serviceBag, "No serviceBag")

	local FeaturesDescendants = script.Parent.Features:GetDescendants()

    for _, instance in FeaturesDescendants do
        if instance:IsA("ModuleScript") and instance.Name:lower():find("service") then
            self._ServiceBag:GetService(instance)
        end
    end
end

function InitService.Start(self: Module, serviceBag: ServiceBag.ServiceBag)
	GameRefs:Start()
end

return InitService :: Module