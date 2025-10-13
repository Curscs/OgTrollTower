--[=[
    @class WheelServiceClient
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local Types = require("./Types")

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")
local Signal = require("Signal")
local MapCache = require("MapCache")
local Promise = require("Promise")

-- [ Constants ] --

-- [ Variables ] --
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "WheelService")
local DataServiceRemotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "DataService")

-- [ Module Table ] --
local WheelServiceClient = {}

-- [ Types ] --
type WheelData = Types.WheelData

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _WhenReadyPromise: Promise.Promise<any>,
    WheelData: MapCache.Object<number>,
    WheelSpinnedSignal: Signal.Signal<any>,
}

export type Module = typeof(WheelServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function WheelServiceClient.BuySpins(self: Module, amount: number)
    Remotes:FireServer("BuySpins", amount)
end

function WheelServiceClient.Spin(self: Module)
    Remotes:FireServer("Spin")
end

function WheelServiceClient.WhenReady(self: Module)
    return self._WhenReadyPromise
end

function WheelServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")

    self._WhenReadyPromise = Promise.new()
    self.WheelData = MapCache.new()
    self.WheelSpinnedSignal = Signal.new()
end

function WheelServiceClient.Start(self: Module)
    Remotes:Connect("WheelSpinned", function(packet: string)
        self.WheelSpinnedSignal:Fire(packet)
    end)

    Remotes:Connect("WheelDataChanged", function(packet: MapCache.Diff<number>)
        self.WheelData:ApplyDiff(packet)
    end)

    DataServiceRemotes:PromiseInvokeServer("GetData", {"Wheel"}):Then(function(success: boolean, packet: WheelData)
        if not success then
            error("[WheelServiceClient] Failed to get Wheel data from server")
        end

        local Diff = {
            Added = packet,
            Updated = {},
            Removed = {},
        }

        self.WheelData:ApplyDiff(Diff)

        self._WhenReadyPromise:Resolve()
    end)
end

return WheelServiceClient :: Module