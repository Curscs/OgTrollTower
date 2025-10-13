--[=[
    @class WheelUIController
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- [ Imports ] --
local Types = require("./Types")

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local WheelUIRefs = require("WheelUIRefs")
local WheelConfig = require("WheelConfig")
local ButtonUtil = require("ButtonUtil")
local Maid = require("Maid")
local Debounce = require("Debounce")
local PromiseUtils = require("PromiseUtils")

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
local WheelUIController = {}

-- [ Types ] --
type WheelData = Types.WheelData
type WheelServiceClient = typeof(require("WheelServiceClient"))
type UIController = typeof(require("UIController"))

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _WheelServiceClient: WheelServiceClient,
    _UIController: UIController,
    _WheelAnimating: boolean,
    _Spins: number,
}

export type Module = typeof(WheelUIController) & ModuleData

-- [ Private Functions ] --
function FormatHHMMSS(totalSeconds: number): string
	totalSeconds = math.max(0, math.floor(totalSeconds))
    local h = math.floor(totalSeconds / 3600)
	local m = math.floor((totalSeconds % 3600) / 60)
	local s = totalSeconds % 60
	return string.format("%02d:%02d:%02d", h, m, s)
end

function PlaySpinAnimation(finalRotation: number, onComplete: () -> ()?)
    local Current = WheelUIRefs.Wheel.Rotation % 360
    WheelUIRefs.Wheel.Rotation = Current

    local EXTRA_SPINS= math.random(2,4)
    local TOTAL_ROTATION = EXTRA_SPINS * 360  + finalRotation

    local Animation = TweenService:Create(WheelUIRefs.Wheel, SPINANIM_TWEENINFO, { Rotation = -(TOTAL_ROTATION)})

    Animation.Completed:Connect(function()
        Animation:Destroy()

        if onComplete then
            onComplete()
        end
    end)

    Animation:Play()
end

function UpdateSlotVisuals()
    local Elements = WheelUIRefs.Elements
    
    for rewardName, rewardData in pairs(WheelConfig.Rewards) do
        local ElementFolder = Elements:WaitForChild(tostring(rewardData.Slot)) :: Folder
        local Icon = ElementFolder:WaitForChild("Icon") :: ImageLabel
        local Title = ElementFolder:WaitForChild("Title") :: TextLabel

        Icon.Image = rewardData.Image
        Title.Text = rewardName
    end
end

function _SetupSpinButtonText(self: Module)
    local Debounce = Debounce.new(1)

    self._Maid:GiveTask(RunService.RenderStepped:Connect(function()
        Debounce:Try(function()
            local WheelData: WheelData = self._WheelServiceClient.WheelData:GetAll()

            if WheelData.Spins == nil then
                warn("[WheelUIController] WheelData.Spins is nil")
                return
            end

            if WheelData.Spins > 0 then
                WheelUIRefs.SpinText.Text = tostring(WheelData.Spins) .. " Spins"
            else
                WheelUIRefs.SpinText.Text = FormatHHMMSS(WheelData.NextFreeSpin - os.clock())
            end
        end)
    end))
end

-- [ Public Functions ] --
function WheelUIController.OnSpin(self: Module, reward: string)
    local Rewards = WheelConfig.Rewards
    local RewardSlot = Rewards[reward]["Slot"]

    self._WheelAnimating = true
    PlaySpinAnimation(SLOT_ANGLES[RewardSlot], function()
        self._WheelAnimating = false
    end)
end

function WheelUIController.Toggle(self: Module, action: string?)
    if not action then
        self._UIController:Auto(WheelUIRefs.WheelUI)
    elseif action == "Close" then
        self._UIController:Close(WheelUIRefs.WheelUI)
    end
end

function WheelUIController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._WheelServiceClient = self._ServiceBag:GetService(require("WheelServiceClient"))
    self._UIController = self._ServiceBag:GetService(require("UIController"))
    self._WheelAnimating = false
end

function WheelUIController.Start(self: Module)
    task.spawn(function()
        PromiseUtils.all({
            WheelUIRefs:WhenReady(),
            self._WheelServiceClient:WhenReady()
        }):Then(function()
            self._WheelServiceClient.WheelSpinnedSignal:Connect(function(reward: string)
                self:OnSpin(reward)
            end)
    
            WheelUIRefs.Spin.Activated:Connect(function()
                ButtonUtil:Press(WheelUIRefs.Spin)

                if self._WheelAnimating == true then
                    return
                end
                
                self._WheelServiceClient:Spin()
            end)
    
            WheelUIRefs.Close.Activated:Connect(function()
                ButtonUtil:Press(WheelUIRefs.Close)
    
                self:Toggle()
            end)
    
            WheelUIRefs.Buy1Spin.Activated:Connect(function()
                ButtonUtil:Press(WheelUIRefs.Buy1Spin)

                self._WheelServiceClient:BuySpins(1)
            end)
    
            WheelUIRefs.Buy3Spins.Activated:Connect(function()
                ButtonUtil:Press(WheelUIRefs.Buy3Spins)

                self._WheelServiceClient:BuySpins(3)
            end)
    
            WheelUIRefs.Buy10Spins.Activated:Connect(function()
                ButtonUtil:Press(WheelUIRefs.Buy10Spins)

                self._WheelServiceClient:BuySpins(10)
            end)
    
            self:Toggle("Close")
    
            UpdateSlotVisuals()
            _SetupSpinButtonText(self)
        end)
    end)
end

return WheelUIController :: Module