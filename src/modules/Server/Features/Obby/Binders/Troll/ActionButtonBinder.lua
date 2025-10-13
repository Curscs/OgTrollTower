--[=[
    @class ActionButtonBinder
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ActionButtonRefBuilder = require("ActionButtonRefBuilder")
local Promise = require("Promise")
local DebounceUtil = require("DebounceUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ActionButtonBinder = {}
ActionButtonBinder.__index = ActionButtonBinder
ActionButtonBinder.Tag = "ActionButtonBinder"

-- [ Types ] --

export type ObjectData = {
    _Instance: Model,
    _ActionButtonRefs: ActionButtonRefBuilder.Structure,

    _Attributes: {
        Cooldown: number,
        OnCooldown: boolean,
    },
    _AttributeConns: {
        [string]: RBXScriptConnection
    },

    _DelayPromise: Promise.Promise<any>?
}
export type Object = ObjectData & Module
export type Module = typeof(ActionButtonBinder)

-- [ Private Functions ] --
local function GetCharacterRoot(player: Player): BasePart?
    local Character = player.Character
    if not Character then return end
    return Character:FindFirstChild("HumanoidRootPart") :: BasePart
end

function _UpdateAttribute(self: Object, name: string, value: any)
    if self._Attributes[name] == nil then
        error(("Tried to update unknown attribute '%s'"):format(name))
        return
    end

    if self._Attributes[name] == value then
        return
    end

    self._Attributes[name] = value

    if self._Instance:GetAttribute(name) == value then
        return
    end

    self._Instance:SetAttribute(name, value)
end

function _SetupAttribute(self: Object, name: string, defaultValue: any, connect: boolean?, onChange: (value: any) -> ()?)
    local Instance = self._Instance
    local Attribute = Instance:GetAttribute(name)

    if Attribute == nil and defaultValue ~= nil then
        Instance:SetAttribute(name, defaultValue)
        Attribute = defaultValue
    end

    self._Attributes[name] = Attribute

    local OldConn = self._AttributeConns[name]
    if OldConn then OldConn:Disconnect() end
    if not connect then return end
    
    self._AttributeConns[name] = self._Instance:GetAttributeChangedSignal(name):Connect(function()
        local Value = self._Instance:GetAttribute(name)

        _UpdateAttribute(self, "OnCooldown", Value)

        if onChange then
            onChange(Value)
        end
    end)
end

-- [ Public Functions ] --
function ActionButtonBinder.new(instance: Instance, serviceBag: ServiceBag.ServiceBag): Object
    local self = setmetatable({} :: any, ActionButtonBinder) :: Object

    if not instance:IsA("Model") then
        error("instance is not a Model")
    end

    self._Instance = instance
    self._ActionButtonRefs = ActionButtonRefBuilder(self._Instance)

    self._Attributes = {
        Cooldown = instance:GetAttribute("Cooldown") :: number,
        OnCooldown = instance:GetAttribute("OnCooldown") :: boolean
    }
    self._AttributeConns = {}

    self._DelayPromise = nil
    
    return self
end

function ActionButtonBinder.Activate(self: Object)
    local Cooldown = math.max(0, self._Attributes.Cooldown)

    if self._Attributes.OnCooldown then
        return
    end

    _UpdateAttribute(self, "OnCooldown", true)

    if self._DelayPromise then
        self._DelayPromise:Destroy()
        self._DelayPromise = nil
    end

    self._DelayPromise = Promise.delay(Cooldown, function()
        if not self._Instance or not self._Instance.Parent then
            return
        end

        _UpdateAttribute(self, "OnCooldown", false)
    end)
end

function ActionButtonBinder.BinderAdded(self: Object)
    _SetupAttribute(self, "OnCooldown", false, true)

    self._ActionButtonRefs.Upper.Touched:Connect(function(hit)
        local Character = hit.Parent
        local Player = Players:GetPlayerFromCharacter(Character)

        if not Player then
            return
        end
        
        if not DebounceUtil:Try(tostring(Player.UserId) .. "/ActionButtonBinder/ButtonPress", 0.3) then
            return
        end

        local PlayerRoot = GetCharacterRoot(Player)

        if not PlayerRoot then
            warn("Player root not found for player:", Player.Name)
            return
        end
        
        local PlayerPosition = Vector3.new(PlayerRoot.Position.X, 0, PlayerRoot.Position.Z)
        local ButtonPositon = Vector3.new(self._ActionButtonRefs.Upper.Position.X, 0, self._ActionButtonRefs.Upper.Position.Z)

        local Radius = self._ActionButtonRefs.Upper.Size.X/2 + 5 -- offset is 5
        local Distance = (PlayerPosition - ButtonPositon).Magnitude

        if Distance > Radius then
            warn(("Player %s is too far from the button to activate it. Distance: %.2f, Allowed Radius: %.2f"):format(Player.Name, Distance, Radius))
            return
        end
        
        self:Activate()
    end)
end

return  ActionButtonBinder