--[=[
    @class PushPartBinderClient
]=]

-- [ Roblox Services ] --
local TweenService = game:GetService("TweenService")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local PushPartStructure = require("PushPartStructure")

-- [ Constants ] --
local TWEEN_INFO = TweenInfo.new(20)

-- [ Variables ] --

-- [ Module Table ] --
local PushPartBinderClient = {}
PushPartBinderClient.__index = PushPartBinderClient
PushPartBinderClient.Tag = "PushPartBinder"

-- [ Types ] --

export type ObjectData = {
    _Instance: BasePart,
    _PushPartStructure: PushPartStructure.Structure,
    _Attributes: {
        Power: number,
    },
    
}
export type Object = ObjectData & Module
export type Module = typeof(PushPartBinderClient)

-- [ Private Functions ] --
local function _SetupTextureAnimation(self: Object)
    while true do
        local Animation = TweenService:Create(self._PushPartStructure.Texture, TWEEN_INFO, { OffsetStudsV = 100})
        Animation:Play()
        Animation.Completed:Wait()
    end
end

-- [ Public Functions ] --
function PushPartBinderClient.new(instance: Instance, serviceBag: ServiceBag.ServiceBag): Object
    local self = setmetatable({} :: any, PushPartBinderClient) :: Object

    if not instance:IsA("BasePart") then
        error("instance is not a BasePart")
    end

    self._Instance = instance
    self._PushPartStructure = PushPartStructure(self._Instance)

    self._Attributes = {
        Power = (self._Instance:GetAttribute("Power") :: number) or 10,
    }
    
    return self
end

function PushPartBinderClient.BinderAdded(self: Object)
    self._Instance.AssemblyLinearVelocity = (-self._Instance.CFrame.LookVector) * self._Attributes.Power

    _SetupTextureAnimation(self)
end

return  PushPartBinderClient