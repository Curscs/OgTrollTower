--[=[
    @class HidablePartBinderClient
]=]

-- [ Roblox Services ] --
local TweenService = game:GetService("TweenService")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Binder = require("Binder")
local AssetProvider = require("AssetProvider")
local Promise = require("Promise")
local GameRefs = require("GameRefs")

-- [ Types ] --

-- [ Constants ] --
local TWEENINFO = TweenInfo.new(0.5)

-- [ Variables ] --

-- [ Details ] --
local HidablePartBinderClient = {}
HidablePartBinderClient.__index = HidablePartBinderClient
HidablePartBinderClient.Tag = "HidablePartBinder"

export type ObjectData = {
    _Instance: BasePart,
    _ExclamationUI: BillboardGui,

    _Attributes: {
        ID: string,
        Cooldown: number,
    },
    
    _Visible: boolean,
    _Tween: Tween?,
    _Promise: Promise.Promise<any>?,
}
export type Object = ObjectData & Module
export type Module = typeof(HidablePartBinderClient)

-- [ Private Functions ] --
local function ContructExclamationUI(instance: BasePart | MeshPart): BillboardGui
    local ExclamationUI = AssetProvider:Get({"UIs", "ExclamationUI"}) :: BillboardGui
    ExclamationUI.Parent = instance
    ExclamationUI.StudsOffset = Vector3.new(0, instance.Size.Y/2 + 2, 0)

    return ExclamationUI
end

local function _TransparencyAnimation(self: Object, value: number, onComplete: () -> ()?)
    local Animation = TweenService:Create(self._Instance, TWEENINFO, { Transparency = value })

    if self._Tween then
        self._Tween:Destroy()
    end

    self._Tween = Animation

    Animation.Completed:Connect(function()
        Animation:Destroy()

        if onComplete then
            onComplete()
        end
    end)

    Animation:Play()
end

-- [ Public Functions ] --
function HidablePartBinderClient.new(instance: Instance, serviceBag: ServiceBag.ServiceBag): Object
    local self = setmetatable({} :: any, HidablePartBinderClient) :: Object

    if not instance:IsA("BasePart") then
        error("instance is not a BasePart or MeshPart")
    end

    -- Main
    self._Instance = instance
    self._ExclamationUI = ContructExclamationUI(instance)

    -- Attributes
    self._Attributes = {
        ID = (instance:GetAttribute("ID") :: string) or error("Missing ID attribute"),
        Cooldown = (instance:GetAttribute("Cooldown") :: number) or error("Missing ID attribute")
    }

    -- Misc
    self._Visible = true
    self._Tween = nil
    self._Promise = nil
    
    return self
end

function HidablePartBinderClient.Hide(self: Object)
    if self._Visible == false then
        return
    end

    self._Visible = false

    if self._Promise then
        self._Promise:Destroy()
        self._Promise = nil
    end

    self._Instance.CanCollide = false
    self._ExclamationUI.Enabled = false
    
    _TransparencyAnimation(self, 1, function()
        self._Promise = Promise.delay(math.max(0, self._Attributes.Cooldown), function()
            if self._Visible == true then
                return
            end
            self._Visible = true
            self._Instance.CanCollide = true
            self._ExclamationUI.Enabled = true
            _TransparencyAnimation(self, 0)
        end)
    end)
end

function HidablePartBinderClient.BinderAdded(self: Object, binderObject: Binder.Binder<any>)
    task.spawn(function()
        GameRefs:WhenReady():Wait()

        for _, instance in GameRefs.ActionButtons:GetChildren() do
            if not instance:HasTag("ActionButtonBinder") and instance:GetAttribute("ID") ~= self._Attributes.ID then
                continue
            end

            instance:GetAttributeChangedSignal("OnCooldown"):Connect(function()
                local Value = instance:GetAttribute("OnCooldown")

                if Value == false then
                    return
                end

                self:Hide()
            end)
        end
    end)
end

return  HidablePartBinderClient