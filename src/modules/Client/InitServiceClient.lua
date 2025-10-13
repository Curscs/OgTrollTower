--[=[
	@class InitServiceClient
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
local UIRefs = require("UIRefs")
local WheelUIRefs = require("WheelUIRefs")
local HUDButtonsUIRefs = require("HUDButtonsUIRefs")
local HUDOffersUIRefs = require("HUDOffersUIRefs")
local GiftsUIRefs = require("GiftsUIRefs")
local HUDStatsUIRefs = require("HUDStatsUIRefs")

-- [ Types ] --

-- [ Variables ] --
local _Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "InitService")

-- [ Module Table ] --
local InitServiceClient = {}

type ModuleData = {
	_ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(InitServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function InitServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
	if self._ServiceBag ~= nil then
		error("Service already initialized")
	end
	self._ServiceBag = assert(serviceBag, "No serviceBag")

	local FeaturesDescendants = script.Parent.Features:GetDescendants()

	for _, instance in FeaturesDescendants do
        if instance:IsA("ModuleScript") and (instance.Name:lower():find("service") or instance.Name:lower():find("controller") or instance.Name:lower():find("cache")) then
            self._ServiceBag:GetService(instance)
        end
    end
end

function InitServiceClient.Start(self: Module)
	task.spawn(function()
		GameRefs:Start()
		UIRefs:Start()
		WheelUIRefs:Start()
		HUDButtonsUIRefs:Start()
		HUDOffersUIRefs:Start()
		GiftsUIRefs:Start()
		HUDStatsUIRefs:Start()
	end)
end

return InitServiceClient :: Module