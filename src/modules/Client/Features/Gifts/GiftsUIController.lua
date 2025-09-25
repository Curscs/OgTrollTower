--[=[
    @class GiftController
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GiftController = {}

-- [ Types ] --
type GiftServiceClient = typeof(require("GiftServiceClient"))

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GiftServiceClient: GiftServiceClient
}

export type Module = typeof(GiftController) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GiftController.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._GiftServiceClient = self._ServiceBag:GetService(require("GiftServiceClient"))
end

function GiftController.Start(self: Module)
    
end

return GiftController :: Module