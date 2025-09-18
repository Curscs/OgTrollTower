--[=[
    @class HUDOffersUIController
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local DebounceUtil = require("DebounceUtil")
local HUDOffersUIRefs = require("HUDOffersUIRefs")
local ButtonUtil = require("ButtonUtil")

-- [ Constants ] --
local TOTAL_OFFERS = 2
local TWEEN_INFO = TweenInfo.new(1)

local DEFAULT_POSITION = UDim2.new(0, 0, 0, 0)
local HIDDEN_POSITION = UDim2.new(0, -400, 0, 0)


-- [ Variables ] --

-- [ Module Table ] --
local HUDOffersUIController = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _CurrentCycle: number,
}

export type Module = typeof(HUDOffersUIController) & ModuleData

-- [ Private Functions ] --
function AnimateUIToPosition(ui: GuiObject, position: UDim2, onCompleted: () -> ()?)
    local Animation = TweenService:Create(ui, TWEEN_INFO, { Position = position })

    Animation.Completed:Connect(function()
        Animation:Destroy()

        if onCompleted then
            onCompleted()
        end
    end)

    Animation:Play()
end

function _SetupOffers(self: Module)
    for i = 1, TOTAL_OFFERS do
        local OfferUI = HUDOffersUIRefs["Offer" .. tostring(i)] :: Frame

        if not OfferUI then
            error("OfferUI not found for index " .. tostring(i))
        end

        _SetupProducts(self, OfferUI)
        
        OfferUI.Position = HIDDEN_POSITION
    end
end

function _SetupProducts(self: Module, offerUI: GuiObject)
    for _, instance in offerUI:GetChildren() do
        if not instance:IsA("ImageButton") then
            continue
        end

        instance.Activated:Connect(function()
            ButtonUtil:Press(instance)
        end)
    end
end

function _CycleOffers(self: Module)
    local PreviousOfferUI = HUDOffersUIRefs["Offer" .. tostring(self._CurrentCycle)] :: Frame

    if not PreviousOfferUI then
        error("PreviousOfferUI not found for index " .. tostring(self._CurrentCycle))
    end

    if self._CurrentCycle == TOTAL_OFFERS then
        self._CurrentCycle = 1
    else
        self._CurrentCycle += 1
    end

    local NewOfferUI = HUDOffersUIRefs["Offer" .. tostring(self._CurrentCycle)] :: Frame

    if not PreviousOfferUI then
        error("PreviousOfferUI not found for index " .. tostring(self._CurrentCycle))
    end

    AnimateUIToPosition(PreviousOfferUI, HIDDEN_POSITION, function()
        AnimateUIToPosition(NewOfferUI, DEFAULT_POSITION)
    end)
end


-- [ Public Functions ] --
function HUDOffersUIController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._CurrentCycle = 1
end

function HUDOffersUIController.Start(self: Module)
    task.spawn(function()
        HUDOffersUIRefs:WhenReady():Wait()
        _SetupOffers(self)

        RunService.RenderStepped:Connect(function()
            if not DebounceUtil:Try("HUDOffersUIController/Cycle", 8) then
                return
            end

            _CycleOffers(self)
        end)
    end)
end

return HUDOffersUIController :: Module