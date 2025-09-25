--[=[
    @class GiftServiceClient
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")

-- [ Constants ] --

-- [ Variables ] --
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "GiftService")

-- [ Module Table ] --
local GiftServiceClient = {}

-- [ Types ] --

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(GiftServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GiftServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._GiftsData = {}
end

function GiftServiceClient.Start(self: Module)

end

return GiftServiceClient :: Module