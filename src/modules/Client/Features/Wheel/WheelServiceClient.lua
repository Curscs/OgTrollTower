--[=[
    @class WheelServiceClient
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")
local WheelUIRefs = require("WheelUIRefs")
local WheelUIController = require("WheelUIController")

-- [ Constants ] --

-- [ Variables ] --
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "WheelService")

-- [ Module Table ] --
local WheelServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _WheelUIController: WheelUIController.Module,
}

export type Module = typeof(WheelServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function WheelServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._WheelUIController = self._ServiceBag:GetService(WheelUIController)
end

function WheelServiceClient.Start(self: Module)
    task.spawn(function()
        WheelUIRefs:WhenReady():Wait()

        WheelUIRefs.Spin.Activated:Connect(function()
            Remotes:FireServer("Spin")
        end)

        Remotes:Connect("WheelSpinned", function(reward: string)
            self._WheelUIController:Spin(reward)
        end)
    end)
end

return WheelServiceClient :: Module