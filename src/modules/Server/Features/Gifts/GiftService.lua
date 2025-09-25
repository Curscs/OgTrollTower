--[=[
    @class GiftService
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
local GiftsConfig = require("GiftsConfig")
local RemoteGate = require("RemoteGate")
local GiftTypesShared = require("GiftTypesShared")

-- [ Constants ] --

-- [ Variables ] --
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "GiftService")

-- [ Module Table ] --
local GiftService = {}

-- [ Types ] --
type GiftsData = {
    [string]: { NextClaim: number, Claimed: boolean }
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GiftsDatas: { [Player]: GiftTypesShared.GiftsPlayerData },
}

export type Module = typeof(GiftService) & ModuleData

-- [ Private Functions ] --
function _InitPlayerData(self: Module, player: Player)
    local GiftsData: GiftsData = {}

    for giftNum, giftData in pairs(GiftsConfig.Gifts) do
        GiftsData[giftNum] = {
            NextClaim = os.clock() + giftData.Time,
            Claimed = false,
        }
    end

    self._GiftsDatas[player] = GiftsData
end

function _ClaimGift(self: Module, player: Player, giftNum: string): any
    local GiftsData = self._GiftsDatas[player]

    if not GiftsData then
        warn("[GiftService] No GiftsData found for player:", player)
        return
    end

    local GiftData = GiftsData[giftNum]

    if not GiftData then
        warn("[GiftService] No GiftData found for giftNum:", giftNum, "player:", player)
        return
    end

    if GiftData.NextClaim > os.clock() then
        warn("[GiftService] Gift cannot be claimed yet. Next claim available at:", GiftData.NextClaim, "Current time:", os.clock(), "Player:", player, "GiftNum:", giftNum)
        return
    end

    GiftData.Claimed = true

    return
end

-- [ Public Functions ] --
function GiftService.GetGiftsData(self: Module, player: Player)
    return self._GiftsDatas[player]
end

function GiftService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._GiftsDatas = {}
end

function GiftService.Start(self: Module)
    Remotes:Bind("GetGiftsData", function(player: Player)
        local Success, Data = RemoteGate(function()
            return self:GetGiftsData(player)
        end)

        if not Success then
            return
        end

        return Data
    end)

    Remotes:Connect("ClaimGift", function(player: Player, giftNum: string)
        local Success, _ = RemoteGate(function()
            return _ClaimGift(self, player, giftNum)
        end)

        if not Success then
            return
        end
    end)

    Players.PlayerAdded:Connect(function(player: Player)
        _InitPlayerData(self, player)
    end)
end

return GiftService :: Module