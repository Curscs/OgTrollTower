--[=[
    @class UIScaleBinder
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

-- [ Constants ] --
local DEFAULT_SCALE = 1
local MIN_SCALE = 0.3
local MAX_SCALE = 1.1
local TARGET_RESOLUTION = Vector2.new(1920, 1080)

-- [ Variables ] --
local Camera = workspace.CurrentCamera
local Current_Scale = DEFAULT_SCALE

-- [ Module Table ] --
local UIScaleBinder = {}
UIScaleBinder.__index = UIScaleBinder
UIScaleBinder.Tag = "UIScaleBinder"

-- [ Types ] --

export type ObjectData = {
    _ServiceBag: any,
	_Maid: Maid.Maid,
	_Instance: any,
}
export type Object = ObjectData & Module
export type Module = typeof(UIScaleBinder)

-- [ Private Functions ] --

-- [ Public Functions ] --
function UIScaleBinder.new(instance: Instance, serviceBag: ServiceBag.ServiceBag): Object
    local self = setmetatable({} :: any, UIScaleBinder) :: Object

    self._ServiceBag = serviceBag
	self._Maid = Maid.new()
	self._Instance = instance

	assert(self._Instance:IsA("UIScale"), "Instance must be a UIScale")

	-- Listen to camera resize
	self._Maid:GiveTask(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		self:UpdateScale()
	end))

	-- Initial apply
	self:UpdateScale()
    
    return self
end

function UIScaleBinder.ApplyScale(self: Object)
	-- Check if UI is in a forced hidden state (scale 0 and invisible)
	local Parent = self._Instance.Parent
	if self._Instance.Scale == 0 and Parent and not Parent.Visible then
		-- UI is intentionally hidden, just update SavedScale for when it reopens
		self._Instance:SetAttribute("SavedScale", Current_Scale)
		return
	end
	
	-- Check if UI is currently being animated (has a running tween)
	local isAnimating = self._Instance:GetAttribute("IsAnimating")
	if isAnimating then
		-- Update SavedScale but don't interfere with ongoing animation
		self._Instance:SetAttribute("SavedScale", Current_Scale)
		return
	end
	
	self._Instance.Scale = Current_Scale
	self._Instance:SetAttribute("SavedScale", Current_Scale)
end

function UIScaleBinder.UpdateScale(self: Object)
	local viewport = Camera.ViewportSize

	local widthRatio = viewport.X / TARGET_RESOLUTION.X
	local heightRatio = viewport.Y / TARGET_RESOLUTION.Y

	local averageRatio = (widthRatio + heightRatio) / 2
	local calculatedScale = math.clamp(averageRatio, MIN_SCALE, MAX_SCALE)

	Current_Scale = calculatedScale
	self:ApplyScale()
end

return  UIScaleBinder