--[=[
    @class ToolService
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")
local AssetProvider = require("AssetProvider")
-- [ Constants ] --

-- [ Variables ] --
local _Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "ToolService")

-- [ Module Table ] --
local ToolService = {}

-- [ Types ] --
type DataService = typeof(require("DataService"))

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataService: DataService,
    _PlrsToPlrTools: { [Player]: { [string]: Tool }}
}

export type Module = typeof(ToolService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolService.CheckIfOwns(self: Module, player: Player, toolName: string)
    local PlrTools = self._PlrsToPlrTools[player]

    if PlrTools[toolName] then
        return true
    else
        return false
    end
end

function ToolService.StoreTool(self: Module, player: Player, toolName: string)
    local Success = self._DataService:SetData(player, true, {"Tools", toolName}, true)

    if not Success then
        warn("[ToolService] Failed to store tool for player:", player, "tool:", toolName)
        return
    end

    self:AddTool(player, toolName)
end

function ToolService.AddTool(self: Module, player: Player, toolName: string)
    local PlrTools = self._PlrsToPlrTools[player]

    if self:CheckIfOwns(player, toolName) then
        warn(string.format("Player %s already has tool %s", tostring(player), tostring(toolName)))
        return
    end

    local ToolInstance = AssetProvider:Get({"Tools", toolName})

    if not ToolInstance then
        warn(string.format("Tool %s could not be found for player %s", tostring(toolName), tostring(player)))
        return
    end

    ToolInstance.Parent = player.Backpack

    PlrTools[toolName] = ToolInstance
end

function ToolService.RemoveTool(self: Module, player: Player, toolName: string)
    local PlrTools = self._PlrsToPlrTools[player]

    if self:CheckIfOwns(player, toolName) then
        warn(string.format("Player %s does not have tool %s", tostring(player), tostring(toolName)))
        return
    end

    local ToolInstance = PlrTools[toolName]

    if not ToolInstance then
        warn(string.format("Tool %s could not be found for player %s", tostring(toolName), tostring(player)))
        return
    end

    ToolInstance:Destroy()

    PlrTools[toolName] = nil
end

function ToolService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._DataService = self._ServiceBag:GetService(require("DataService"))
    self._PlrsToPlrTools = {}
end

function ToolService.Start(self: Module)
    Players.PlayerAdded:Connect(function(player: Player)
        self._PlrsToPlrTools[player] = {}

        local Success, StoredPlayerTools: { [string]: unknown } = self._DataService:GetData(player, {"Tools"})

        print(StoredPlayerTools)

        if not Success then
            warn(string.format("Failed to get tools for player %s", tostring(player)))
            return
        end

        for toolName, _ in StoredPlayerTools do
            self:AddTool(player, toolName)
        end
    end)
end

return ToolService :: Module