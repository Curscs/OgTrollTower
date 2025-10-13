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
local MapCacheUtils = require("MapCacheUtils")

-- [ Constants ] --

-- [ Variables ] --
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "GiftService")

-- [ Module Table ] --
local GiftService = {}

-- [ Types ] --
type GiftID = string

type DataService = typeof(require("DataService"))
type ToolService = typeof(require("ToolService"))

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataService: DataService,
    _ToolService: ToolService,
    _PlayerToGiftData: { [Player]: GiftTypesShared.GiftsPlayerData },
}

export type Module = typeof(GiftService) & ModuleData

-- [ Private Functions ] --
function _InitPlayerData(self: Module, player: Player)
    local GiftsData: GiftTypesShared.GiftsPlayerData = {} 

    for giftID, giftData in pairs(GiftsConfig.Gifts) do
        GiftsData[giftID] = {
            NextClaim = os.clock() + giftData.Time,
            Claimed = false,
        }
    end

    self._PlayerToGiftData[player] = GiftsData
end

function _RewardPlayer(self: Module, player: Player, giftType: string, giftName: string)
    if giftType == "Currency" then
        local Amount, CurrencyName = giftName:split(" ")[1], giftName:split(" ")[2]
        self._DataService:AddData(player, tonumber(Amount) or 0, {CurrencyName})
    elseif giftType == "Tool" then
        self._ToolService:StoreTool(player, giftName)
    elseif giftType == "HDAdmin" then
        -- do something
    end
end

function _ClaimGift(self: Module, player: Player, giftID: GiftID): any
    local GiftsData = self._PlayerToGiftData[player]
    local GiftConfig = GiftsConfig.Gifts[giftID]

    if not GiftsData then
        warn("[GiftService] No GiftsData found for player:", player)
        return
    end

    local GiftData = GiftsData[giftID]

    if not GiftsData then
        warn("[GiftService] No GiftData found for giftNum:", giftID, "player:", player)
        return
    end

    if GiftData.Claimed == true then
        warn("[GiftService] Gift already claimed for giftNum:", giftID, "player:", player)
        return
    end

    if GiftData.NextClaim > os.clock() then
        warn("[GiftService] Gift cannot be claimed yet. Next claim available at:", GiftsData.NextClaim, "Current time:", os.clock(), "Player:", player, "GiftNum:", giftID)
        return
    end

    GiftData.Claimed = true

    _RewardPlayer(self, player, GiftConfig.Type, GiftConfig.Name)

    Remotes:FireClient("GiftsDataChanged", player, MapCacheUtils:CreateDiff(nil, nil, { [giftID] = GiftData }, nil))

    return
end

-- [ Public Functions ] --
function GiftService.GetGiftsData(self: Module, player: Player)
    return self._PlayerToGiftData[player]
end

function GiftService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")

    self._DataService = self._ServiceBag:GetService(require("DataService"))
    self._ToolService = self._ServiceBag:GetService(require("ToolService"))

    self._PlayerToGiftData = {}
end

function GiftService.Start(self: Module)
    Remotes:DeclareEvent("GiftsDataChanged")

    Remotes:Bind("GetGiftsData", function(player: Player)
        local Success, Data = RemoteGate(function()
            return MapCacheUtils:CreateDiff(nil, self:GetGiftsData(player)) -- creates tabls like Added = {}, Updated = {}, Removed = {} with data inside or none
        end)

        if not Success then
            return
        end

        return Data
    end)

    Remotes:Connect("ClaimGift", function(player: Player, giftID: GiftID)
        local Success, _ = RemoteGate(function()
            return _ClaimGift(self, player, giftID)
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