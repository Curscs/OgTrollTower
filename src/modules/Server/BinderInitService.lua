--[=[
    @class BinderInitService
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Nevermore ] --
local RbxRequire = require
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Binder = require("Binder")

-- [ Variables ] --

-- [ Module Table ] --
local BinderInitService = {}

-- [ Types ] --
type BoundObject = { 
    BinderAdded: ((self: any, binder: Binder.Binder<any>) -> ())?, 
    BinderRemoving: ((self: any, binder: Binder.Binder<any>) -> ())?, 
    BinderRemoved: ((self: any, binder: Binder.Binder<any>) -> ())? 
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Binders: { [string]: Binder.Binder<any> }
}

export type Module = typeof(BinderInitService) & ModuleData

-- [ Private Functions ] --
local function MakeBinder(serviceBag: ServiceBag.ServiceBag, tag: string, classModule)
    local BinderObject = Binder.new(tag, function(instance)
        return classModule.new(instance, serviceBag)
    end)

    return serviceBag:GetService(BinderObject)
end

-- [ Client Functions ] --
function BinderInitService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")

    self._Binders = {}

    local FeaturesDescendants = script.Parent.Features:GetDescendants()

    for _, instance in FeaturesDescendants do
        if instance:IsA("ModuleScript") and instance.Name:lower():find("binder") then
            local Module = RbxRequire(instance)
            local Tag = Module.Tag or error("Module.Tag is missing for " .. instance.Name)
            self._Binders[Tag] = MakeBinder(self._ServiceBag, Tag, Module)
        end
    end
end

function BinderInitService.Start(self: Module, serviceBag: ServiceBag.ServiceBag)
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

return BinderInitService :: Module