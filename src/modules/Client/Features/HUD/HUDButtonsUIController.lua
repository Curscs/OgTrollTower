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
local ButtonUtil = require("ButtonUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local HUDButtonsUIController = {}

-- [ Types ] --
type WheelUIController = typeof(require("WheelUIController"))
type GiftsUIController = typeof(require("GiftsUIController"))

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _WheelUIController: WheelUIController,
    _GiftsUIController: GiftsUIController,
}

export type Module = typeof(HUDButtonsUIController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function HUDButtonsUIController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._WheelUIController = self._ServiceBag:GetService(require("WheelUIController"))
    self._GiftsUIController = self._ServiceBag:GetService(require("GiftsUIController"))
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
                elseif instance.Name == "Gifts" then
                    self._GiftsUIController:Toggle()
                end
            end)
        end
    end)
end

return HUDButtonsUIController :: Module