--[=[
    @class DamagePartBinder
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local DamageService = require("DamageService")
local Binder = require("Binder")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DamagePartBinder = {}
DamagePartBinder.__index = DamagePartBinder
DamagePartBinder.Tag = "DamagePartBinder"

-- [ Types ] --

export type ObjectData = {
    _Instance: BasePart,
    _DamageService: typeof(DamageService),
    _Cache: { [string]: number },

    _Damage: number,
    _Cooldown: number,
}
export type Object = ObjectData & Module
export type Module = typeof(DamagePartBinder)

-- [ Private Functions ] --
local function _Debounce(self: Object, player: Player)
    local UserID = tostring(player.UserId)

    if not self._Cache[UserID] or self._Cache[UserID] < os.clock() then
        self._Cache[UserID] = os.clock() + self._Cooldown
        return true
    end

    return false
end

-- [ Public Functions ] --
function DamagePartBinder.new(instance: Instance, serviceBag: ServiceBag.ServiceBag): Object
    local self = setmetatable({} :: any, DamagePartBinder) :: Object

    if not instance:IsA("BasePart") then
        error("Instance is not a BasePart")
    end

    self._Instance = instance
    self._DamageService = serviceBag:GetService(DamageService)
    self._Cache = {}

    self._Damage = instance:GetAttribute("Damage") :: number
    self._Cooldown = instance:GetAttribute("Cooldown") :: number
    
    return self
end

function DamagePartBinder.BinderAdded(self: Object, binderObject: Binder.Binder<any>)
    self._Instance.Touched:Connect(function(hit)
        local Character = hit.Parent
        local Player = Players:GetPlayerFromCharacter(Character)

        if not Player then
            return
        end

        if not _Debounce(self, Player) then
            return
        end

        self._DamageService:DamagePlayer(Player, self._Damage)
    end)
end

return  DamagePartBinder
