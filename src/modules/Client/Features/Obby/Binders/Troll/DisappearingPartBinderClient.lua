local TweenService = game:GetService("TweenService")
--[=[
    @class DisappearingPartBinderClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Binder = require("Binder")

-- [ Constants ] --
local TWEEN = TweenInfo.new(0.5)

-- [ Variables ] --

-- [ Module Table ] --
local DisappearingPartBinderClient = {}
DisappearingPartBinderClient.__index = DisappearingPartBinderClient
DisappearingPartBinderClient.Tag = "DisappearingPartBinder"

-- [ Types ] --

export type ObjectData = {
    _Instance: BasePart,
    _Tween: Tween?,
    _Active: boolean,

    _Attributes: {
        Cooldown: number,
        Delay: number
    }
}
export type Object = ObjectData & Module
export type Module = typeof(DisappearingPartBinderClient)

-- [ Private Functions ] --
local function _TransparencyAnimation(self: Object, value: number, onComplete: () -> ())
    local Animation = TweenService:Create(self._Instance, TWEEN, { Transparency = value })

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
function DisappearingPartBinderClient.new(instance: Instance, serviceBag: ServiceBag.ServiceBag): Object
    local self = setmetatable({} :: any, DisappearingPartBinderClient) :: Object

    if not instance:IsA("BasePart") then
        error("Instance is not a BasePart")
    end
    
    self._Instance = instance
    self._Tween = nil
    self._Active = true
    
    self._Attributes = {
        Cooldown = instance:GetAttribute("Cooldown") :: number,
        Delay = instance:GetAttribute("Delay") :: number
    }

    return self
end

function DisappearingPartBinderClient.BinderAdded(self: Object, binder: Binder.Binder<any>)
    self._Instance.Touched:Connect(function(hit)
        if self._Active ~= true then
            return
        end

        local Parent = hit and hit.Parent
		if not Parent then return end

		local Humanoid = Parent:FindFirstChildOfClass("Humanoid")
		if not Humanoid then return end

        self._Active = false

        task.wait(self._Attributes.Delay)
        
        _TransparencyAnimation(self, 1, function()
            self._Instance.CanCollide = false
            task.wait(self._Attributes.Cooldown)
            _TransparencyAnimation(self, 0, function()
                self._Instance.CanCollide = true
                self._Active = true
            end)
        end)
    end)
end

return  DisappearingPartBinderClient