--[=[
    @class GiftController
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local MapCache = require("MapCache")
local GiftsConfig = require("GiftsConfig")
local Table = require("Table")
local AssetProvider = require("AssetProvider")
local GiftUIRefBuilder = require("GiftUIRefBuilder")
local GiftsUIRefs = require("GiftsUIRefs")
local ButtonUtil = require("ButtonUtil")
local Maid = require("Maid")
local DebounceUtil = require("DebounceUtil")
local GiftTypesShared = require("GiftTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GiftController = {}

-- [ Types ] --
type GiftID = string

type GiftServiceClient = typeof(require("GiftServiceClient"))
type UIController = typeof(require("UIController"))

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Maid: Maid.Maid,
    _GiftServiceClient: GiftServiceClient,
    _GiftUIs: { [GiftID]: GuiObject },
    _UIController: UIController,
}

export type Module = typeof(GiftController) & ModuleData

-- [ Private Functions ] --
function FormatMMSS(totalSeconds: number): string
	totalSeconds = math.max(0, math.floor(totalSeconds))
	local m = math.floor(totalSeconds / 60)
	local s = totalSeconds % 60
	return string.format("%02d:%02d", m, s)
end

function _SetupGift(self: Module, giftID: GiftID)
    if Table.count(self._GiftUIs) >= GiftsConfig.MaxGifts then
            warn("[GiftsUIController] Max gifts reached, cannot add more gifts!")
        return
    end

    local GiftData = self._GiftServiceClient.GiftsData:Get(giftID); if not GiftData then return end
    local GiftUI = AssetProvider:Get({"UIs", "GiftUI"}) :: ImageButton
    local GiftUIRefs = GiftUIRefBuilder(GiftUI)
    local SpecificGiftConfig = GiftsConfig.Gifts[giftID]

    local function UpdateGiftUpperText(text: string)
        if GiftUIRefs.GiftTime.Text == text then
            return
        end

        GiftUIRefs.GiftTime.Text = text
    end
    
    GiftUI.Parent = GiftsUIRefs.Container
    GiftUI.LayoutOrder = tonumber(giftID) or 0
    GiftUIRefs.BackGradient.Color = SpecificGiftConfig.FrontGradient
    GiftUIRefs.FrontGradient.Color = SpecificGiftConfig.BackGradient
    GiftUIRefs.Icon.Image = SpecificGiftConfig.Image
    GiftUIRefs.GiftName.Text = SpecificGiftConfig.Name

    GiftUI.Activated:Connect(function()
        ButtonUtil:Press(GiftUI)

        self._GiftServiceClient:ClaimGift(giftID)
    end)

    -- cache --
    self._GiftUIs[giftID] = GiftUI

    self._Maid:GiveTask(RunService.RenderStepped:Connect(function()
        DebounceUtil:Try("GiftsUIController/" .. giftID .. "RenderStepped", 1)

        local GiftData = self._GiftServiceClient.GiftsData:Get(giftID); if not GiftData then return end

        if GiftData.Claimed == true then
            UpdateGiftUpperText("Claimed")
        elseif GiftData.NextClaim < os.clock() and not GiftData.Claimed then
            UpdateGiftUpperText("Ready")
        else
            GiftUIRefs.GiftTime.Text = FormatMMSS(GiftData.NextClaim - os.clock())
        end
    end))
end

-- [ Public Functions ] --
function GiftController.Toggle(self: Module, action: string?)
    if not action then
        self._UIController:Auto(GiftsUIRefs.GiftsUI)
    elseif action == "Close" then
        self._UIController:Close(GiftsUIRefs.GiftsUI)
    end
end

function GiftController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Maid = Maid.new()
    self._GiftServiceClient = self._ServiceBag:GetService(require("GiftServiceClient"))
    self._UIController = self._ServiceBag:GetService(require("UIController"))

    self._GiftUIs = {}
end

function GiftController.Start(self: Module)
    GiftsUIRefs:WhenReady():Then(function()
        self._GiftServiceClient.GiftsData:Observe(function(_, lastDiff: MapCache.Diff<GiftTypesShared.GiftData>, _)
            for giftID, giftData in pairs(lastDiff.Added) do
                _SetupGift(self, giftID)
            end
        end)

        GiftsUIRefs.Close.Activated:Connect(function()
            ButtonUtil:Press(GiftsUIRefs.Close)
            self:Toggle()
        end)

        self:Toggle("Close")
    end)
end

return GiftController :: Module