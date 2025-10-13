--[=[
    @class ToolGiverBinderClient
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Binder = require("Binder")
local ToolGiverRefBuilder = require("ToolGiverRefBuilder")
local ZonePlus = require("ZonePlus")
local AttributeValue = require("AttributeValue")
local Remoting = require("Remoting")
local ZonePlus = require("ZonePlus")

-- [ Constants ] --

-- [ Variables ] --
local Player = Players.LocalPlayer
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "ToolGiverBinder")

-- [ Module Table ] --
local ToolGiverBinderClient = {}
ToolGiverBinderClient.__index = ToolGiverBinderClient
ToolGiverBinderClient.Tag = "ToolGiverBinder"

-- [ Types ] --
type NotificationController = typeof(require("NotificationController"))

export type ObjectData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NotificationController: NotificationController,
    _Instance: Model,
    _ToolGiverRefs: ToolGiverRefBuilder.Structure,
    _Zone: {
        localPlayerEntered: RBXScriptSignal
    },
    _Attributes: {
        ToolName: AttributeValue.AttributeValue<string>,
        Currency: AttributeValue.AttributeValue<string>,
        Price: AttributeValue.AttributeValue<number>,
    },
}
export type Object = ObjectData & Module
export type Module = typeof(ToolGiverBinderClient)

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolGiverBinderClient.new(instance: Instance, serviceBag: ServiceBag.ServiceBag): Object
    local self = setmetatable({} :: any, ToolGiverBinderClient) :: Object

    if not instance:IsA("Model") then
        error("instance is not a Model")
    end

    self._ServiceBag = serviceBag
    self._NotificationController = self._ServiceBag:GetService(require("NotificationController"))
    self._Instance = instance
    self._ToolGiverRefs = ToolGiverRefBuilder(instance)
    self._Zone = ZonePlus.new(instance)
    self._Attributes = {
        ToolName = AttributeValue.new(instance, "ToolName", "Gravity Coil"),
        Currency = AttributeValue.new(instance, "Currency", "None"),
        Price = AttributeValue.new(instance, "Price", 0),
    }
    
    return self
end

function ToolGiverBinderClient.BinderAdded(self: Object, binder: Binder.Binder<any>)
    self._Zone.localPlayerEntered:Connect(function(player: Player)
        if player == Player then
            self._NotificationController:Notify("Choice", false, {
                choice1 = "No",
                choice2 = "Yes",
                description = "Are you sure u want to buy a(n) " .. self._Attributes.ToolName.Value .. " for " .. (self._Attributes.Price.Value == 0 and "Free" or self._Attributes.Price.Value .. " " .. self._Attributes.Currency.Value),
                cb1 = function()
                end,
                cb2 = function()
                    Remotes:FireServer("GiveTool", self._Instance)
                end
            })
        end
    end)
end

return  ToolGiverBinderClient