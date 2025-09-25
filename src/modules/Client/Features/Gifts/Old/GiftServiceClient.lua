--[=[
    @class GiftServiceClient
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local GiftUIController = require("./GiftsUIController")
local Types = require("./Types")
local Cache = require("./Cache")

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")

-- [ Constants ] --

-- [ Variables ] --
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "GiftService")

-- [ Module Table ] --
local GiftServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GiftsUIController: GiftUIController.Module
}

export type Module = typeof(GiftServiceClient) & ModuleData

-- [ Private Functions ] --
function _InitPlayerData(self: Module)
    Remotes:PromiseInvokeServer("GetGiftsData", {"Gifts"}):Then(function(giftsPlayerData: Types.GiftsPlayerData)
        if giftsPlayerData == nil then
            error("Issue with data initialization of gifts")
        end

        Cache._GiftsData = giftsPlayerData

        self._GiftsUIController:SetupGiftUIs(giftsPlayerData)
    end)
end

-- [ Public Functions ] --
function GiftServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")

    self._GiftsUIController = self._ServiceBag:GetService(GiftUIController)
end

function GiftServiceClient.Start(self: Module)
    task.spawn(function()
        self._GiftsUIController:WhenReady()

        _InitPlayerData(self)
    end)
end

return GiftServiceClient :: Module