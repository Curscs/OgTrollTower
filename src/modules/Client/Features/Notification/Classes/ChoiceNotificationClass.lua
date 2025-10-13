--[=[
    @class ChoiceNotificationClass
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local ChoiceNotificatioUIRefBuilder = require("../RefBuilders/ChoiceNotificationUIRefBuilder")

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local AssetProvider = require("AssetProvider")
local ButtonUtil = require("ButtonUtil")
local Maid = require("Maid")
local Signal = require("Signal")
local UIAnimUtil = require("UIAnimUtil")
local UIRefs = require("UIRefs")

-- [ Constants ] --
local OPEN_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TWEENINFO = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- [ Variables ] --

-- [ Module Table ] --
local ChoiceNotificationClass = {}
ChoiceNotificationClass.__index = ChoiceNotificationClass

-- [ Types ] --
export type ChoiceNotifParams = { 
    choice1: string, 
    choice2: string,
    description: string,
    cb1: () -> (), 
    cb2: () -> () 
}

export type ObjectData = {
    _Maid: Maid.Maid,
    ResolvedSignal: Signal.Signal<any>,
    Resolved: boolean,
    _Callback1: () -> (),
    _Callback2: () -> (),
    _UI: GuiObject
}
export type Object = ObjectData & Module
export type Module = typeof(ChoiceNotificationClass)

-- [ Private Functions ] --
function _CreateChoiceNotificationUI(self: Object, choice1: string, choice2: string, description: string): GuiObject
    local ChoiceNotificationUI = AssetProvider:Get({"UIs", "ChoiceNotificationUI"})
    local ChoiceNotificationUIRefs = ChoiceNotificatioUIRefBuilder(ChoiceNotificationUI)
    ChoiceNotificationUIRefs.UIScale.Scale = 0
    ChoiceNotificationUI.Parent = UIRefs.Notifications

    ChoiceNotificationUIRefs.Option1Text.Text = choice1
    ChoiceNotificationUIRefs.Option2Text.Text = choice2
    ChoiceNotificationUIRefs.Description.Text = description

    local function OnOption(optionButton: ImageButton, cb: () -> ())
        ButtonUtil:Press(optionButton)

        UIAnimUtil:UIShrink(ChoiceNotificationUI, CLOSE_TWEENINFO, function()
            cb()
            self.ResolvedSignal:Fire()
        end)
    end
    
    ChoiceNotificationUIRefs.Option1.Activated:Connect(function()
        OnOption(ChoiceNotificationUIRefs.Option1, self._Callback1)
    end)

    ChoiceNotificationUIRefs.Option2.Activated:Connect(function()
        OnOption(ChoiceNotificationUIRefs.Option2, self._Callback2)
    end)

    UIAnimUtil:UIExpand(ChoiceNotificationUI, OPEN_TWEENINFO)

    return ChoiceNotificationUI
end

-- [ Public Functions ] --
function ChoiceNotificationClass.new(params: ChoiceNotifParams): Object
    local self = setmetatable({} :: any, ChoiceNotificationClass) :: Object

    self._Maid = Maid.new()
    self.ResolvedSignal = Signal.new()
    self.Resolved = false
    self._Callback1 = params.cb1
    self._Callback2 = params.cb2
    self._UI = _CreateChoiceNotificationUI(self, params.choice1, params.choice2, params.description)
    self._Maid:GiveTask(self._UI)

    return self
end

function ChoiceNotificationClass.Destroy(self: Object)
    self._Maid:DoCleaning()
end


return ChoiceNotificationClass