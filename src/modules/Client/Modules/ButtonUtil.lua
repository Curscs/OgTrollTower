--[=[
    @class ButtonUtil
]=]
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)
local TweenService = game:GetService("TweenService")

-- [ Imports ] --

-- [ Constants ] --
local SHRINK_TWEENINFO = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
local EXPAND_TWEENINFO = TweenInfo.new(0.1, Enum.EasingStyle.Linear)

-- [ Variables ] --

-- [ Module Table ] --
local ButtonUtil = {}

-- [ Types ] --
export type ModuleData = {
    _Tween: Tween?
}

export type Module = typeof(ButtonUtil) & ModuleData

-- [ Private Functions ] --
function _DestroyTween(self: Module)
    if self._Tween then
        self._Tween:Destroy()
        self._Tween = nil
    end
end

-- [ Public Functions ] --
function ButtonUtil.Press(self: Module, button: GuiButton)
    self:Shrink(button, function()
        self:Expand(button)
    end)
end

function ButtonUtil.Shrink(self: Module, button: GuiButton, onComplete: () -> ()?)
    local UIScale = button:FindFirstChildOfClass("UIScale") :: UIScale
    if not UIScale then
        UIScale = Instance.new("UIScale", button)
    end

    _DestroyTween(self)

    local Animation = TweenService:Create(UIScale, SHRINK_TWEENINFO, { Scale = 0.9 })

    self._Tween = Animation

    Animation.Completed:Connect(function()
        _DestroyTween(self)

        if onComplete then
            onComplete()
        end
    end)

    Animation:Play()
end

function ButtonUtil.Expand(self: Module, button: GuiButton, onComplete: () -> ()?)
    local UIScale = button:FindFirstChildOfClass("UIScale") :: UIScale
    if not UIScale then
        UIScale = Instance.new("UIScale")
    end

    _DestroyTween(self)

    local Animation = TweenService:Create(UIScale, EXPAND_TWEENINFO, { Scale = 1 })

    self._Tween = Animation

    Animation.Completed:Connect(function()
        _DestroyTween(self)

        if onComplete then
            onComplete()
        end
    end)

    Animation:Play()
end

return ButtonUtil :: Module