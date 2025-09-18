--[=[
    @class HUDButtonsUIController
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local HUDButtonsUIRefs = require("HUDButtonsUIRefs")
local WheelUIController = require("WheelUIController")
local ButtonUtil = require("ButtonUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local HUDButtonsUIController = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _WheelUIController: WheelUIController.Module,
}

export type Module = typeof(HUDButtonsUIController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function HUDButtonsUIController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._WheelUIController = self._ServiceBag:GetService(WheelUIController)
end

function HUDButtonsUIController.Start(self: Module)
    task.spawn(function()
        HUDButtonsUIRefs:WhenReady():Wait()

        for _, instance in HUDButtonsUIRefs.HUDButtonsUI:GetChildren() do
            if not instance:IsA("ImageButton") then
                continue
            end

            instance.Activated:Connect(function()
                ButtonUtil:Press(instance)

                if instance.Name == "Wheel" then
                    self._WheelUIController:Toggle()
                end
            end)
        end
    end)
end

return HUDButtonsUIController :: Module