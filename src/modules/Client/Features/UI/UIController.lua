--[=[
    @class UIController
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local UIAnimUtil = require("UIAnimUtil")

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

-- [ Public Functions ] --
function UIController.CloseOpened(self: Module)
    for ui in self._OpenUIs do
        self:Close(ui)
    end
end

function UIController.Auto(self: Module, ui: GuiObject)
    if self._OpenUIs[ui] then
        self:Close(ui)
    else
        self:Open(ui)
    end
end

function UIController.Open(self: Module, ui: GuiObject)
    self:CloseOpened()
    self._OpenUIs[ui] = true
    UIAnimUtil:UIExpand(ui, OPEN_TWEENINFO)
end

function UIController.Close(self: Module, ui: GuiObject)
    self._OpenUIs[ui] = nil
    UIAnimUtil:UIShrink(ui, CLOSE_TWEENINFO)
end

function UIController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._OpenUIs = {}
    self._UITweens = {}
end

return UIController :: Module