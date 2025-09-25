--[=[
    @class GiftServiceClient
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")
local GiftTypesShared = require("GiftTypesShared")
local MapCache = require("MapCache")
local Promise = require("Promise")

-- [ Constants ] --

-- [ Variables ] --
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "GiftService")

-- [ Module Table ] --
local GiftServiceClient = {}

-- [ Types ] --

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GiftsData: MapCache.Object<GiftTypesShared.GiftsPlayerData>,
    _Ready: Promise.Promise<any>,
}

export type Module = typeof(GiftServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GiftServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._GiftsData = MapCache.new()
    self._Ready = Promise.new()
end

function GiftServiceClient.Start(self: Module)
    Remotes:PromiseInvokeServer("GetGiftsData"):Then(function(packet: MapCache.Diff)
        self._GiftsData:ApplyDiff(packet)
    end)

    self._Ready:Then(function()

    end)
end

return GiftServiceClient :: Module