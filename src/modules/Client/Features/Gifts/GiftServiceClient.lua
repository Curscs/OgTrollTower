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
local PromiseUtils = require("PromiseUtils")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "GiftService")

-- [ Module Table ] --
local GiftServiceClient = {}

-- [ Types ] --
type GiftID = string

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    GiftClaimedSignal: Signal.Signal<any>,
    GiftsData: MapCache.Object<GiftTypesShared.GiftData>,
}

export type Module = typeof(GiftServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GiftServiceClient.ClaimGift(self: Module, giftID: GiftID)
    Remotes:FireServer("ClaimGift", giftID)
end

function GiftServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self.GiftsData = MapCache.new()
end

function GiftServiceClient.Start(self: Module)
    local P1 = Remotes:PromiseInvokeServer("GetGiftsData"):Then(function(packet: MapCache.Diff<GiftTypesShared.GiftData>)
        self.GiftsData:ApplyDiff(packet)
    end)

    PromiseUtils.all({P1}):Catch(function(err)
        warn("[GiftServiceClient]", err)
    end)

    Remotes:Connect("GiftsDataChanged", function(packet: MapCache.Diff<GiftTypesShared.GiftData>)
        self.GiftsData:ApplyDiff(packet)
    end)
end

return GiftServiceClient :: Module