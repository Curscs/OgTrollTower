--[=[
    @class HUDStatsUIController
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --
local HUDStatUIRefBuilder = require("./RefBuilders/HUDStatUIRefBuilder")

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local AbbreviateNumber = require("AbbreviateNumber")
local HUDStatsUIRefs = require("HUDStatsUIRefs")

-- [ Constants ] --

-- [ Variables ] --
local Player = Players.LocalPlayer

-- [ Module Table ] --
local HUDStatsUIController = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(HUDStatsUIController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function HUDStatsUIController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function HUDStatsUIController.Start(self: Module)
    task.spawn(function()
        HUDStatsUIRefs:WhenReady():Then(function()
            for _, instance in HUDStatsUIRefs.HUDStatsUI:GetChildren() do
                if not instance:IsA("Frame") then
                    continue
                end
    
                local LeaderstatInstance = Player:WaitForChild("leaderstats"):WaitForChild(instance.Name, 5) 
    
                if not LeaderstatInstance or not LeaderstatInstance:IsA("NumberValue") then
                    warn("LeaderstatInstance not found for: " .. instance.Name)
                    return
                end
    
                local HUDStatUIRefs = HUDStatUIRefBuilder(instance)
    
                local function UpdateAmount()
                    HUDStatUIRefs.CurrencyAmount.Text = AbbreviateNumber(LeaderstatInstance.Value, 2)
                end
    
                UpdateAmount()
    
                LeaderstatInstance:GetPropertyChangedSignal("Value"):Connect(function()
                    UpdateAmount()
                end)
            end
        end)
    end)
end

return HUDStatsUIController :: Module