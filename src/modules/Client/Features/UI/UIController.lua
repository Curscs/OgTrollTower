local TweenService = game:GetService("TweenService")
--[=[
    @class UIController
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local WheelUIRefs = require("WheelUIRefs")

-- [ Constants ] --
local OPEN_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- [ Variables ] --

-- [ Module Table ] --
local UIController = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _OpenUIs: {
        [GuiObject]: unknown,
    },
    _UITweens: {
        [GuiObject]: Tween,
    }
}

export type Module = typeof(UIController) & ModuleData

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

function _PlayOpenAnimation(self: Module, ui: GuiObject, onComplete: () -> ()?)
    local UIScale = ui:FindFirstChildOfClass("UIScale") :: UIScale

    if not UIScale then
        warn("UIScale not found in UI object: " .. tostring(ui))
        return
    end

    ui.Visible = true

    ui:SetAttribute("IsAnimating", false)
    _DestroyTween(self, ui)

    local Animation = TweenService:Create(UIScale, OPEN_TWEENINFO, { Scale = UIScale:GetAttribute("SavedScale") })

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

function _PlayCloseAnimation(self: Module, ui: GuiObject, onComplete: () -> ()?)
    local UIScale = ui:FindFirstChildOfClass("UIScale") :: UIScale

    if not UIScale then
        warn("UIScale not found in UI object: " .. tostring(ui))
        return
    end

    ui:SetAttribute("IsAnimating", false)
    _DestroyTween(self, ui)

    local Animation = TweenService:Create(UIScale, CLOSE_TWEENINFO, { Scale = 0 })

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
function UIController.Auto(self: Module, ui: GuiObject)
    if self._OpenUIs[ui] then
        self:Close(ui)
    else
        self:Open(ui)
    end
end

function UIController.Open(self: Module, ui: GuiObject)
    self._OpenUIs[ui] = true
    _PlayOpenAnimation(self, ui)
end

function UIController.Close(self: Module, ui: GuiObject)
    self._OpenUIs[ui] = nil
    _PlayCloseAnimation(self, ui)
end

function UIController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._OpenUIs = {}
    self._UITweens = {}
end

function UIController.Start(self: Module)
    task.spawn(function()
        WheelUIRefs:WhenReady():Wait()

        self:Close(WheelUIRefs.WheelUI)
    end)
end

return UIController :: Module