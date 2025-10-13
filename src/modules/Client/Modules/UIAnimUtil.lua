local TweenService = game:GetService("TweenService")
--[=[
    @class UIAnimUtil
]=]
-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UIAnimUtil = {}

UIAnimUtil._UITweens = {} :: { GuiObject: unknown }

-- [ Types ] --

export type Module = typeof(UIAnimUtil)

-- [ Private Functions ] --
function _DestroyTween(self: Module, ui: GuiObject)
    local UIScale = ui:FindFirstChildOfClass("UIScale") :: UIScale

    if not UIScale then
        warn("UIScale not found in UI object: " .. tostring(ui))
        return
    end
    
    if self._UITweens[ui] then
        self._UITweens[ui]:Destroy()
        self._UITweens[ui] = nil
    end
end

function UIAnimUtil.UIExpand(self: Module, ui: GuiObject, tweenInfo: TweenInfo, onComplete: () -> ()?)
    local UIScale = ui:FindFirstChildOfClass("UIScale") :: UIScale

    if not UIScale then
        warn("UIScale not found in UI object: " .. tostring(ui))
        return
    end

    ui.Visible = true

    ui:SetAttribute("IsAnimating", false)
    _DestroyTween(self, ui)

    local Animation = TweenService:Create(UIScale, tweenInfo, { Scale = UIScale:GetAttribute("SavedScale") })

    UIScale:SetAttribute("IsAnimating", true)
    self._UITweens[ui] = Animation

    Animation.Completed:Connect(function()
        ui:SetAttribute("IsAnimating", false)
        _DestroyTween(self, ui)

        if onComplete then
            onComplete()
        end
    end)

    Animation:Play()
end

function UIAnimUtil.UIShrink(self: Module, ui: GuiObject, tweenInfo: TweenInfo, onComplete: () -> ()?)
    local UIScale = ui:FindFirstChildOfClass("UIScale") :: UIScale

    if not UIScale then
        warn("UIScale not found in UI object: " .. tostring(ui))
        return
    end

    ui:SetAttribute("IsAnimating", false)
    _DestroyTween(self, ui)

    local Animation = TweenService:Create(UIScale, tweenInfo, { Scale = 0 })

    UIScale:SetAttribute("IsAnimating", true)
    self._UITweens[ui] = Animation

    Animation.Completed:Connect(function()
        ui:SetAttribute("IsAnimating", false)
        _DestroyTween(self, ui)

        ui.Visible = false

        if onComplete then
            onComplete()
        end
    end)

    Animation:Play()
end
-- [ Public Functions ] --

return UIAnimUtil :: Module