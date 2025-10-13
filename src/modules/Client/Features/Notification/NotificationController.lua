--[=[
    @class NotificationController
]=]

-- [ Roblox Services ] --

-- [ Imports ] --
local ChoiceNotificationClass = require("./Classes/ChoiceNotificationClass")

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local UIRefs = require("UIRefs")

-- [ Constants ] --
local MAX_NOTIFICATIONS = 1

-- [ Variables ] --

-- [ Module Table ] --
local NotificationController = {}

-- [ Types ] --
type NotifParams = ChoiceNotificationClass.ChoiceNotifParams

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Notifications: { any }
}

export type Module = typeof(NotificationController) & ModuleData

-- [ Private Functions ] --
function NotificationClassSelector(notifType: string, params: NotifParams)
    if notifType then
        return ChoiceNotificationClass.new(params)
    else
        error("Unknown or unsupported notification type: " .. tostring(notifType))
    end
end

-- [ Public Functions ] --
function NotificationController.Notify(self: Module, notifType: string, important: boolean?, params: NotifParams)
    if #self._Notifications >= MAX_NOTIFICATIONS and not important then
        return
    end

    local NotifObject = NotificationClassSelector(notifType, params)

    table.insert(self._Notifications, NotifObject)
    
    local Removed = false
    local function RemoveNotif()
        if Removed then
            return
        end
        Removed = true

        local I = table.find(self._Notifications, NotifObject)

        if I then
            table.remove(self._Notifications, I)
        end

        NotifObject:Destroy()
    end
    
    NotifObject.ResolvedSignal:Once(function()
        RemoveNotif()
    end)

    if NotifObject.Resolved == true then
        RemoveNotif()
    end
end

function NotificationController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Notifications = {}
end

function NotificationController.Start(self: Module)
    task.spawn(function()
        UIRefs:WhenReady():Then(function()
        end)
    end)
end

return NotificationController :: Module