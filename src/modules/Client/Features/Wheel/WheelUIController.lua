
--[=[
    @class WheelController
]=]

-- [ Roblox Services ] --
local TweenService = game:GetService("TweenService")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local WheelUIRefs = require("WheelUIRefs")
local WheelConfig = require("WheelConfig")
local ButtonUtil = require("ButtonUtil")
local UIController = require("UIController")

-- [ Constants ] --
local SPINANIM_TWEENINFO = TweenInfo.new(
    3,                            -- Longer duration
    Enum.EasingStyle.Quart, -- Dramatic curve
    Enum.EasingDirection.Out,     -- Sharp deceleration
    0,                            -- No repeat
    false,                        -- Don't reverse
    0
)

local SLOT_ANGLES = {
    [1] = 22.5,
    [2] = 67.5,
    [3] = 112.5,
    [4] = 157.5,
    [5] = 202.5,
    [6] = 247.5,
    [7] = 292.5,
    [8] = 337.5,
}

local _SLOT_COUNT = #SLOT_ANGLES

-- [ Variables ] --

-- [ Module Table ] --
local WheelController = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _UIController: UIController.Module,
}

export type Module = typeof(WheelController) & ModuleData

-- [ Private Functions ] --
function PlaySpinAnimation(finalRotation: number)
    local Current = WheelUIRefs.Wheel.Rotation % 360
    WheelUIRefs.Wheel.Rotation = Current

    local EXTRA_SPINS= math.random(2,4)
    local TOTAL_ROTATION = EXTRA_SPINS * 360  + finalRotation

    local Animation = TweenService:Create(WheelUIRefs.Wheel, SPINANIM_TWEENINFO, { Rotation = -(TOTAL_ROTATION)})

    Animation:Play()
end

local function UpdateSlotVisuals()
    local Elements = WheelUIRefs.Elements
    
    for rewardName, rewardData in WheelConfig:GetVar("Rewards") do
        local ElementFolder = Elements:WaitForChild(tostring(rewardData.Slot)) :: Folder
        local Icon = ElementFolder:WaitForChild("Icon") :: ImageLabel
        local Title = ElementFolder:WaitForChild("Title") :: TextLabel

        Icon.Image = rewardData.Image
        Title.Text = rewardName
    end
end

-- [ Public Functions ] --
function WheelController:Spin(reward: string)
    local Rewards = WheelConfig:GetVar("Rewards")
    local RewardSlot = Rewards[reward]["Slot"]
    
    PlaySpinAnimation(SLOT_ANGLES[RewardSlot])
end

function WheelController.Toggle(self: Module, action: string?)
    if not action then
        self._UIController:Auto(WheelUIRefs.WheelUI)
    end
end

function WheelController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._UIController = self._ServiceBag:GetService(UIController)
end

function WheelController.Start(self: Module)
    task.spawn(function()
        WheelUIRefs:WhenReady():Wait()
        UpdateSlotVisuals()

        WheelUIRefs.Spin.Activated:Connect(function()
            ButtonUtil:Press(WheelUIRefs.Spin)
        end)

        WheelUIRefs.Close.Activated:Connect(function()
            ButtonUtil:Press(WheelUIRefs.Close)

            self:Toggle()
        end)
    end)
end

return WheelController :: Module