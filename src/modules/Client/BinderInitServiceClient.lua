--[=[
    @class BinderInitServiceClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Nevermore ] --
local RbxRequire = require
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Binder = require("Binder")
local Table = require("Table")

-- [ Types ] --
type BoundObject = { 
    BinderAdded: ((self: any, binder: Binder.Binder<any>) -> ())?, 
    BinderRemoving: ((self: any, binder: Binder.Binder<any>) -> ())?, 
    BinderRemoved: ((self: any, binder: Binder.Binder<any>) -> ())? 
}

-- [ Variables ] --

-- [ Module Table ] --
local BinderInitServiceClient = {}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Binders: { [string]: Binder.Binder<any> }
}

export type Module = typeof(BinderInitServiceClient) & ModuleData

-- [ Private Functions ] --
local function MakeBinder(serviceBag: ServiceBag.ServiceBag, tag: string, classModule)
    local BinderObject = Binder.new(tag, function(instance)
        return classModule.new(instance, serviceBag)
    end)

    return serviceBag:GetService(BinderObject)
end

-- [ Client Functions ] --
function BinderInitServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")

    self._Binders = {}

    local FeaturesDescendants = script.Parent.Features:GetDescendants()
    local Binders = script.Parent.Binders:GetChildren()
    local Instances = Table.mergeLists(FeaturesDescendants, Binders)

    for _, instance in Instances do
        if instance:IsA("ModuleScript") and instance.Name:lower():find("binderclient") then
            local Module = RbxRequire(instance)
            local Tag = Module.Tag or error("Module.Tag is missing for " .. instance.Name)
            self._Binders[Tag] = MakeBinder(self._ServiceBag, Tag, Module)
        end
    end
end

function BinderInitServiceClient.Start(self: Module, serviceBag: ServiceBag.ServiceBag)
    for tag, Binder in pairs(self._Binders) do
        Binder:GetClassAddedSignal():Connect(function(object: BoundObject)
            if not object.BinderAdded then
                return
            end

            object.BinderAdded(object, Binder)
        end)
        Binder:GetClassRemovedSignal():Connect(function(object: BoundObject)
            if not object.BinderRemoved then
                return
            end

            object.BinderRemoved(object, Binder)
        end)
        Binder:GetClassRemovingSignal():Connect(function(object: BoundObject)
            if not object.BinderRemoving then
                return
            end

            object.BinderRemoving(object, Binder)
        end)
    end
end

return BinderInitServiceClient :: Module