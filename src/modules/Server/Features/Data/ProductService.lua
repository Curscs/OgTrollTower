--[=[
    @class ProductService
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- [ Imports ] --
local ProfileStore = require("./Modules/ProfileStore")
local ProfileConfig = require("./Configs/ProfileConfig")
local ProductsConfig = require("./Configs/ProductsConfig")

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")

-- [ Constants ] --
local PURCHASE_ID_CACHE_SIZE = 100

-- [ Variables ] --
local _Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "ProductService")
local WheelServiceRemotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "WheelService")

-- [ Module Table ] --
local ProductService = {}

-- [ Types ] --
type Profile = ProfileStore.Profile<ProfileConfig.ProfileData>

type ReceiptInfo = {
    PlayerId: number,
    ProductId: number,
    PurchaseId: string,
}

type DataService = typeof(require("DataService"))
type ToolService = typeof(require("ToolService"))
type WheelService = typeof(require("WheelService"))

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataService: DataService,
    _ToolService: ToolService,
    _WheelService: WheelService,
}

export type Module = typeof(ProductService) & ModuleData

-- [ Private Functions ] --
local function PurchaseIdCheckAsync(profile: Profile, purchase_id: string, grant_product: () -> ()): Enum.ProductPurchaseDecision
    if profile:IsActive() == true then

        local purchase_id_cache = profile.Data.PurchaseIdCache

        if purchase_id_cache == nil then
            purchase_id_cache = {}
            profile.Data.PurchaseIdCache = purchase_id_cache
        end

        if table.find(purchase_id_cache, purchase_id) == nil then

            local success, result = pcall(function() grant_product() end)
            if not success then
                warn(`Failed to process receipt:`, profile.Key, purchase_id, result)
                return Enum.ProductPurchaseDecision.NotProcessedYet
            end

            while #purchase_id_cache >= PURCHASE_ID_CACHE_SIZE do
                table.remove(purchase_id_cache, 1)
            end

            table.insert(purchase_id_cache, purchase_id)

        end

        local function is_purchase_saved()
            local saved_cache = profile.LastSavedData.PurchaseIdCache
            return if saved_cache ~= nil then table.find(saved_cache, purchase_id) ~= nil else false
        end

        if is_purchase_saved() == true then
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end

        while profile:IsActive() == true do

            local last_saved_data = profile.LastSavedData

            profile:Save()

            if profile.LastSavedData == last_saved_data then
                profile.OnAfterSave:Connect(function() end):Disconnect()
            end

            if is_purchase_saved() == true then
                return Enum.ProductPurchaseDecision.PurchaseGranted
            end

            if profile:IsActive() == true then
                task.wait(10)
            end

        end

    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end

local function _ProcessReceipt(self: Module, receipt_info: ReceiptInfo)
    local player = Players:GetPlayerByUserId(receipt_info.PlayerId)

    if player ~= nil then

        local profile = self._DataService:GetProfile(player)

        if profile == nil then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        local ProductData = ProductsConfig[tostring(receipt_info.ProductId)]

        local Grant_Product = nil

        if ProductData.Type == "Currency" then
            Grant_Product = function()
                self._DataService:AddData(player, ProductData.CurrencyAmount, {ProductData.CurrencyName})
            end
        elseif ProductData.Type == "Tool" then
            Grant_Product = function()
                self._DataService:SetData(player, true, {"Tools", ProductData.ToolName}, true)
                self._ToolService:AddTool(player, ProductData.ToolName)
            end
        elseif ProductData.Type == "Wheel" then
            Grant_Product = function()
                self._DataService:AddData(player, ProductData.Spins, {"Wheel", "Spins"})
                self._WheelService:WheelDataChanged(player)
            end
        elseif ProductData.Type == "Custom" then
            Grant_Product = ProductData.Func
        end

        return PurchaseIdCheckAsync(
            profile,
            receipt_info.PurchaseId,
            Grant_Product
        )
    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- [ Public Functions ] --
function ProductService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._DataService = self._ServiceBag:GetService(require("DataService"))
    self._ToolService = self._ServiceBag:GetService(require("ToolService"))
    self._WheelService = self._ServiceBag:GetService(require("WheelService"))
end

function ProductService.Start(self: Module)
    MarketplaceService.ProcessReceipt = function(ri: ReceiptInfo)
        return _ProcessReceipt(self, ri)
    end
end

return ProductService :: Module