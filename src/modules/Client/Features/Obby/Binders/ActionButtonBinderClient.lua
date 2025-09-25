--[=[
    @class ActionButtonBinderClient
]=]

-- [ Roblox Services ] --
local TweenService = game:GetService("TweenService")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Binder = require("Binder")
local ActionButtonRefBuilder = require("ActionButtonRefBuilder")

-- [ Types ] --

-- [ Constants ] --
local BUTTON_DOWN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Back)
local BUTTON_UP_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Back)
local BUTTON_ANIMATION_STUDS = 0.5

-- [ Variables ] --

-- [ Details ] --
local ActionButtonBinderClient = {}
ActionButtonBinderClient.__index = ActionButtonBinderClient
ActionButtonBinderClient.Tag = "ActionButtonBinder"

export type ObjectData = {
    -- Main
    _Instance: Model,
    _ActionButtonRefs: ActionButtonRefBuilder.Structure,
    _InitialUpperCFrame: CFrame,

    -- Attributes
    _Attributes: {
        ID: string,
        OnCooldown: boolean,
    },
    _AttributeConns: {
        [string]: RBXScriptConnection
    }
}
export type Object = ObjectData & Module
export type Module = typeof(ActionButtonBinderClient)

-- [ Private Functions ] --
function AnimateButtonDown(instance: Part, InitialCFrame: CFrame, onComplete: () -> ()?)
    instance.Color = Color3.fromRGB(124, 20, 22)
    local NewCFrame = InitialCFrame * CFrame.new(0,-BUTTON_ANIMATION_STUDS,0)
    local Animation = TweenService:Create(instance, BUTTON_DOWN_INFO, { CFrame = NewCFrame })

    Animation.Completed:Connect(function()
        Animation:Destroy()

        if onComplete then
            onComplete()
        end
    end)

    Animation:Play()
end

function AnimateButtonUp(instance: Part, InitialCFrame: CFrame, onComplete: () -> ()?)
    instance.Color = Color3.fromRGB(34, 167, 65)
    local Animation = TweenService:Create(instance, BUTTON_UP_INFO, { CFrame = InitialCFrame })

    Animation.Completed:Connect(function()
        Animation:Destroy()

        if onComplete then
            onComplete()
        end
    end)

    Animation:Play()
end

function _UpdateAttribute(self: Object, name: string, value: any)
    if self._Attributes[name] == nil then
        warn(("Tried to update unknown attribute '%s'"):format(name))
        return
    end

    if self._Attributes[name] == value then
        return
    end

    self._Attributes[name] = value

    if self._Instance:GetAttribute(name) == value then
        return
    end

    self._Instance:SetAttribute(name, value)
end

function _SetupAttribute(self: Object, name: string, defaultValue: any, connect: boolean?, onChange: (value: any) -> ()?)
    local Instance = self._Instance
    local Attribute = Instance:GetAttribute(name)

    if Attribute == nil and defaultValue ~= nil then
        Instance:SetAttribute(name, defaultValue)
        Attribute = defaultValue
    end

    _UpdateAttribute(self, name, Attribute)

    local OldConn = self._AttributeConns[name]
    if OldConn then OldConn:Disconnect() end
    if not connect then return end
    
    self._AttributeConns[name] = self._Instance:GetAttributeChangedSignal(name):Connect(function()
        local Value = self._Instance:GetAttribute(name)

        _UpdateAttribute(self, name, Value)

        if onChange then
            onChange(Value)
        end
    end)
end

-- [ Public Functions ] --
function ActionButtonBinderClient.new(instance: Instance, serviceBag: ServiceBag.ServiceBag): Object
    local self = setmetatable({} :: any, ActionButtonBinderClient) :: Object

    if not instance:IsA("Model") then
        error("instance is not a Model")
    end

    -- Main
    self._Instance = instance
    self._ActionButtonRefs = ActionButtonRefBuilder(self._Instance)
    self._InitialUpperCFrame = self._ActionButtonRefs.Upper.CFrame

    -- Attributes
    self._Attributes = {
        ID = (instance:GetAttribute("ID") :: string) or error("Instance is missing required 'ID' attribute"),
        OnCooldown = instance:GetAttribute("OnCooldown") :: boolean
    }
    self._AttributeConns = {}

    return self
end

function ActionButtonBinderClient.BinderAdded(self: Object, binderObject: Binder.Binder<any>)
    _SetupAttribute(self, "OnCooldown", false, true, function(value: any)
        if value == true then
            AnimateButtonDown(self._ActionButtonRefs.Upper, self._InitialUpperCFrame)
        elseif value == false then
            AnimateButtonUp(self._ActionButtonRefs.Upper, self._InitialUpperCFrame)
        end
    end)
end

return ActionButtonBinderClient