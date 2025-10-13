--[=[
    @class ToolGiverBinder
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Binder = require("Binder")
local ToolGiverRefBuilder = require("ToolGiverRefBuilder")
local ZonePlus = require("ZonePlus")
local AttributeValue = require("AttributeValue")
local Remoting = require("Remoting")
local RemoteGate = require("RemoteGate")
local DebounceUtil = require("DebounceUtil")

-- [ Constants ] --

-- [ Variables ] --
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "ToolGiverBinder")

-- [ Module Table ] --
local ToolGiverBinder = {}
ToolGiverBinder.__index = ToolGiverBinder
ToolGiverBinder.Tag = "ToolGiverBinder"

-- [ Types ] --
type ToolService = typeof(require("ToolService"))
type DataService = typeof(require("DataService"))

export type ObjectData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataService: DataService,
    _ToolService: ToolService,
    _Instance: Model,
    _ToolGiverRefs: ToolGiverRefBuilder.Structure,
    _Attributes: {
        ToolName: AttributeValue.AttributeValue<string>,
        Currency: AttributeValue.AttributeValue<string>,
        Price: AttributeValue.AttributeValue<number>,
    },
}
export type Object = ObjectData & Module
export type Module = typeof(ToolGiverBinder)

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolGiverBinder.new(instance: Instance, serviceBag: ServiceBag.ServiceBag): Object
    local self = setmetatable({} :: any, ToolGiverBinder) :: Object

    if not instance:IsA("Model") then
        error("instance is not a Model")
    end
    
    self._ServiceBag = serviceBag
    self._DataService = self._ServiceBag:GetService(require("DataService"))
    self._ToolService = self._ServiceBag:GetService(require("ToolService"))

    self._Instance = instance
    self._ToolGiverRefs = ToolGiverRefBuilder(instance)
    self._Attributes = {
        ToolName = AttributeValue.new(instance, "ToolName", "Gravity Coil"),
        Currency = AttributeValue.new(instance, "Currency", "None"),
        Price = AttributeValue.new(instance, "Price", 0),
    }

    return self
end

function ToolGiverBinder.GiveTool(self: Object, player: Player)
    if self._ToolService:CheckIfOwns(player, self._Attributes.ToolName.Value) then
        warn("[ToolGiverBinder] Player already owns the tool:", self._Attributes.ToolName.Value, "Player:", player)
        return
    end

    if self._Attributes.Price.Value == 0 then
        self._ToolService:StoreTool(player, self._Attributes.ToolName.Value)
    else
        if self._Attributes.Currency.Value == "None" then
            return
        end

        local Success, PlayerCoins = self._DataService:GetData(player, {self._Attributes.Currency.Value})

        if not Success then
            warn("[ToolGiverBinder] Failed to get player currency data for", player, "currency:", tostring(self._Attributes.Currency.Value))
            return
        end

        if typeof(PlayerCoins) ~= "number" or PlayerCoins <= 0 then
            warn("[ToolGiverBinder] Player does not have any " .. tostring(self._Attributes.Currency.Value) .. " to purchase the tool:", self._Attributes.ToolName.Value, "Player:", player)
            return
        end
    
        if PlayerCoins < self._Attributes.Price.Value then
            warn("[ToolGiverBinder] Player does not have enough " .. tostring(self._Attributes.Currency.Value) .. " to purchase the tool:", self._Attributes.ToolName.Value, "Player:", player)
            return
        end

        self._DataService:SetData(player, PlayerCoins - self._Attributes.Price.Value, {self._Attributes.Currency.Value})

        self._ToolService:StoreTool(player, self._Attributes.ToolName.Value)
    end
end

function ToolGiverBinder.BinderAdded(self: Object, Binder: Binder.Binder<any>)
    Remotes:Connect("GiveTool", function(player: Player, instance: Model)
        local Success, _ = RemoteGate(function()
            if instance ~= self._Instance then
                return
            end

            return self:GiveTool(player)
        end)

        if not Success then
            return
        end
    end)
end

return  ToolGiverBinder