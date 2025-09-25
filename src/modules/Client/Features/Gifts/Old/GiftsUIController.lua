--[=[
    @class GiftsUIController
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Imports ] --
local GiftUIRefBuilder = require("./RefBuilders/GiftUIRefBuilder")
local Types = require("./Types")

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local GiftsConfig = require("GiftsConfig")
local AssetProvider = require("AssetProvider")
local GiftsUIRefs = require("GiftsUIRefs")
local ButtonUtil = require("ButtonUtil")
local Promise = require("Promise")
local Maid = require("Maid")
local DebounceUtil = require("DebounceUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GiftsUIController = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _ReadyPromise: Promise.Promise<any>,
    _Maid: Maid.Maid,
    _Gifts: { [string]: { UI: GuiObject, NextClaim: number } },
}

export type Module = typeof(GiftsUIController) & ModuleData

-- [ Private Functions ] --
local function FormatMMSS(totalSeconds: number): string
	totalSeconds = math.max(0, math.floor(totalSeconds))
	local m = math.floor(totalSeconds / 60)
	local s = totalSeconds % 60
	return string.format("%02d:%02d", m, s)
end

function _GiftClicked(self: Module)
    
end

-- [ Public Functions ] --
function GiftsUIController.UpdateGiftClaimTime()
    
end

function GiftsUIController.SetupGiftUIs(self: Module, giftsPlayerData: Types.GiftsPlayerData)
    local TotalGifts = 0

    for giftNum, giftData in pairs(giftsPlayerData) do
        if TotalGifts >= GiftsConfig.MaxGifts then
            return
        end

        TotalGifts += 1

        local GiftUI = AssetProvider:Get({"UIs", "GiftUI"}) :: ImageButton
        local GiftUIRefs = GiftUIRefBuilder(GiftUI)
        local GiftConfigData = GiftsConfig.Gifts[giftNum]
        
        GiftUI.Parent = GiftsUIRefs.Container
        GiftUI.LayoutOrder = tonumber(giftNum) or 0
        GiftUIRefs.BackGradient.Color = GiftConfigData.FrontGradient
        GiftUIRefs.FrontGradient.Color = GiftConfigData.BackGradient
        GiftUIRefs.Icon.Image = GiftConfigData.Image
        GiftUIRefs.GiftName.Text = GiftConfigData.Name

        GiftUI.Activated:Connect(function()
            ButtonUtil:Press(GiftUI)

            _GiftClicked(self)
        end)

        -- cache --
        self._Gifts[giftNum] = {
            UI = GiftUI,
            NextClaim = giftData.NextClaim
        }

        self._Maid:GiveTask(RunService.RenderStepped:Connect(function()
            DebounceUtil:Try("GiftsUIController/" .. giftNum .. "RenderStepped", 1)
            local NextClaim = self._Gifts[giftNum].NextClaim

            if NextClaim == nil or os.clock() > NextClaim then
                return
            end

            GiftUIRefs.GiftTime.Text = FormatMMSS(NextClaim - os.clock())
        end))
    end
end

function GiftsUIController.WhenReady(self: Module)
    return self._ReadyPromise
end

function GiftsUIController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._ReadyPromise = Promise.new()
    self._Gifts = {}
end

function GiftsUIController.Start(self: Module)
    task.spawn(function()
        GiftsUIRefs:WhenReady():Wait()

        self._ReadyPromise:Resolve()
    end)
end

return GiftsUIController :: Module