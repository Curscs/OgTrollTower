--[=[
    @class WheelService
]=]

-- [ Roblox Services ] --
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")
local ChanceUtil = require("ChanceUtil")
local WheelConfig = require("WheelConfig")
local Promise = require("Promise")
local RemoteGate = require("RemoteGate")
local DebounceUtil = require("DebounceUtil")
local MapCacheUtils = require("MapCacheUtils")

-- [ Constants ] --

-- [ Variables ] --
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "WheelService")

-- [ Module Table ] --
local WheelService = {}

-- [ Types ] --
type DataService = typeof(require("DataService"))
type ToolService = typeof(require("ToolService"))

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataService: DataService,
    _ToolService: ToolService,
    _Cache: {
        Reward: {[string]: {[string]: any}}?,
        Chances: {[string]: number}?,
    },
    _FreeSpinTasks: {[Player]: Promise.Promise<any>},
}

export type Module = typeof(WheelService) & ModuleData

-- [ Private Functions ] --
function PurchaseSpins(player: Player, amount: number)
    if amount == 1 then
        MarketplaceService:PromptProductPurchase(player, 3419408958)
    elseif amount == 3 then
        MarketplaceService:PromptProductPurchase(player, 3422365091)
    elseif amount == 10 then
        MarketplaceService:PromptProductPurchase(player, 3422365088)
    end
end

function _SetupFreeSpin(self: Module, player: Player)
    local Success, Spins = self._DataService:GetData(player, {"Wheel", "Spins"})
    local Success_2, NextFreeSpin = self._DataService:GetData(player, {"Wheel", "NextFreeSpin"})

    if not Success or not Success_2 then
        warn("Failed to get NextFreeSpin for player " .. tostring(player))
        return
    end

    if Spins < 0 then
        return
    end

    if self._FreeSpinTasks[player] then
        self._FreeSpinTasks[player]:Destroy()
        self._FreeSpinTasks[player] = nil
    end

    local Remaining = math.max(0, NextFreeSpin - os.clock())

    self._FreeSpinTasks[player] = Promise.delay(Remaining, function()
        local Success_3, newNextFreeSpin = self._DataService:GetData(player, {"Wheel", "NextFreeSpin"})
        if not Success_3 or newNextFreeSpin > os.clock() then
            return
        end

        self._DataService:AddData(player, 1, {"Wheel", "Spins"})
        self._DataService:SetData(player, os.clock() + WheelConfig.FreeSpinCooldown, {"Wheel", "NextFreeSpin"})

        local Success_4, Data_4 = self._DataService:GetData(player, {"Wheel"})

        if not Success_4 then
            return
        end
    
        Remotes:FireClient("WheelDataChanged", player, MapCacheUtils:CreateDiff(nil,  nil, Data_4))

        _SetupFreeSpin(self, player)
    end)
end

function _RewardPlayer(self: Module, player: Player, rewardType: string, rewardName: string)
    if rewardType == "Currency" then
        local Amount, CurrencyName = rewardName:split(" ")[1], rewardName:split(" ")[2]
        self._DataService:AddData(player, tonumber(Amount) or 0, {CurrencyName})
    elseif rewardType == "Tool" then
        self._ToolService:StoreTool(player, rewardName)
    elseif rewardType == "HDAdmin" then
        -- do something
    end
end

-- [ Public Functions ] --
function WheelService.WheelDataChanged(self: Module, player: Player)
    local Success_2, Data_2 = self._DataService:GetData(player, {"Wheel"})

    if not Success_2 then
        return
    end

    Remotes:FireClient("WheelDataChanged", player, MapCacheUtils:CreateDiff(nil,  nil, Data_2))
end

function WheelService.Spin(self: Module, player: Player)
    local Success, Spins = self._DataService:GetData(player, {"Wheel", "Spins"})

    if not Success then
        warn("Failed to get Spins for player " .. tostring(player))
        return
    end

    if Spins < 1 then
        warn("Player does not have any spins left!")
        return
    end

    local Rewards = self._Cache["Rewards"] or WheelConfig.Rewards
    local Chances = self._Cache["Chances"] or {}

    if next(Chances) == nil then
        for rewardName, rewardData in Rewards do
            Chances[rewardName] = rewardData.Chance
        end
    end

    local ChanceUtilObject = ChanceUtil.new(Chances)
    local RewardName = ChanceUtilObject:Choose()
    local RewardType = Rewards[RewardName]["RewardType"]

    if not self._Cache["Chances"] then
        self._Cache["Chances"] = Chances
    elseif not self._Cache["Rewards"] then
        self._Cache["Rewards"] = Rewards
    end

    self._DataService:AddData(player, -1, {"Wheel", "Spins"})

    _RewardPlayer(self, player, RewardType, RewardName)

    self:WheelDataChanged(player)
    Remotes:FireClient("WheelSpinned", player, RewardName)
end

function WheelService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    
    self._DataService = self._ServiceBag:GetService(require("DataService"))
    self._ToolService = self._ServiceBag:GetService(require("ToolService"))

    self._Cache = {}
    self._FreeSpinTasks = {}
    
    Remotes:DeclareEvent("WheelSpinned")
    Remotes:DeclareEvent("WheelDataChanged")
end

function WheelService.Start(self: Module)
    Remotes:Connect("BuySpins", function(player: Player, amount: number)
        local Success, _ = RemoteGate(function()
            return  PurchaseSpins(player, amount)
        end)

        if not Success then
            return
        end
    end)

    Remotes:Connect("Spin", function(player: Player)
        local Success, _ = RemoteGate(function()
            DebounceUtil:Try(tostring(player.UserId) .. "/WheelService/Spin", 5)
            
            return self:Spin(player)
        end)

        if not Success then
            return
        end
    end)

    Players.PlayerAdded:Connect(function(player: Player)
        _SetupFreeSpin(self, player)
    end)
end

return WheelService :: Module