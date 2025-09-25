--[=[
    @class WheelService
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
local ChanceUtil = require("ChanceUtil")
local WheelConfig = require("WheelConfig")
local DataService = require("DataService")
local Promise = require("Promise")

-- [ Constants ] --

-- [ Variables ] --
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "WheelService")

-- [ Module Table ] --
local WheelService = {}

-- [ Types ] --

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataService: DataService.Module,
    _Cache: {
        Reward: {[string]: {[string]: any}}?,
        Chances: {[string]: number}?,
    },
    _FreeSpinTasks: {[Player]: Promise.Promise<any>},
}

export type Module = typeof(WheelService) & ModuleData

-- [ Private Functions ] --
function _SetupFreeSpin(self: Module, player: Player)
    local Success, Spins = self._DataService:GetData(player, {"Wheel", "Spins"})
    local Success2, NextFreeSpin = self._DataService:GetData(player, {"Wheel", "NextFreeSpin"})

    if not Success or Success2 then
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
        local Success_2, newNextFreeSpin = self._DataService:GetData(player, {"Wheel", "NextFreeSpin"})
        if not Success_2 or newNextFreeSpin > os.clock() then
            return
        end

        self._DataService:AddData(player, 1, {"Wheel", "Spins"})
        self._DataService:SetData(player, os.clock() + WheelConfig.FreeSpinCooldown, {"Wheel", "NextFreeSpin"})

        _SetupFreeSpin(self, player)
    end)
end

function _GiveReward(self: Module, player: Player, reward: string, rewardType: string)
    if rewardType == "Item" then
        self._DataService:SetData(player, true, {"OwnedItems", reward}, true)
    elseif rewardType == "Currency" then
        local Parts = string.split(reward, " ")

        local Amount = tonumber(Parts[1]) or error("Failed to parse amount from reward string: " .. tostring(reward))
        local Currency = Parts[2]

        self._DataService:AddData(player, Amount, {Currency})
    elseif rewardType == "HD Admin" then
        -- soon
    end
end

-- [ Public Functions ] --
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
    local Reward = ChanceUtilObject:Choose()
    local RewardType = Rewards[Reward]["RewardType"]

    _GiveReward(self, player, Reward, RewardType)

    if not self._Cache["Chances"] then
        self._Cache["Chances"] = Chances
    elseif not self._Cache["Rewards"] then
        self._Cache["Rewards"] = Rewards
    end

    Remotes:FireClient("WheelSpinned", player, Reward)
end

function WheelService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    
    self._DataService = self._ServiceBag:GetService(DataService)
    self._Cache = {}
    self._FreeSpinTasks = {}
    
    Remotes:DeclareEvent("WheelSpinned")
end

function WheelService.Start(self: Module)
    Remotes:Connect("Spin", function(player: Player)
        self:Spin(player)
    end)

    Players.PlayerAdded:Connect(function(player: Player)
        _SetupFreeSpin(self, player)
    end)
end

return WheelService :: Module