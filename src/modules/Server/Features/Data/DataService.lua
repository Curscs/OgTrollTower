--[=[
    @class DataService
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local ProfileStore = require("./Modules/ProfileStore")
local ProfileConfig = require("./Configs/ProfileConfig")

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")

-- [ Constants ] --
local KEY = "Dev_7"
local PROFILE_TEMPLATE = ProfileConfig.Template
local DISPLAY_STATS = ProfileConfig.Leaderstats

-- [ Variables ] --
local PlayerStore = ProfileStore.New(KEY, PROFILE_TEMPLATE)
local Profiles = {}
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "DataService")

-- [ Module Table ] --
local DataService = {}

-- [ Types ] --

type Profile = ProfileStore.Profile<ProfileConfig.ProfileData>

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag
}

export type Module = typeof(DataService) & ModuleData

-- [ Private Functions ] --
function GetProfile(player: Player): Profile
    while Profiles[player] == nil do
        task.wait(0.1)
    end

    return Profiles[player]
end

function CreateLeaderstats(player: Player)
    local Profile = GetProfile(player)

    local FolderInstance = Instance.new("Folder", player)
    FolderInstance.Name = "leaderstats"

    for _, displayStat in DISPLAY_STATS do
        local value = Profile.Data[displayStat]
        if value and type(value) == "number" then
            local ValueInstance = Instance.new("NumberValue", FolderInstance)
            ValueInstance.Name = displayStat
            ValueInstance.Value = value
        end
    end
end

function PlayerAdded(player: Player)
    local Profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
        Cancel = function()
            return player.Parent ~= Players
        end,
    })


    if Profile then
        Profile:AddUserId(player.UserId)
        Profile:Reconcile()

        Profile.OnSessionEnd:Connect(function()
            Profile[player] = nil
            player:Kick("Profile seasion end - Please rejoin")
        end)

        if player.Parent == Players then
            Profiles[player] = Profile
            print(`Profile loaded for {player.DisplayName}!`)
            CreateLeaderstats(player)
        else
            Profile:EndSession()
        end
    else
        player:Kick(`Profile load fail - Please rejoin`)
    end
end

function ProcessPath(InitialPath: any, path: { string }, hardSet: boolean?): (boolean, any, any, any)
    local CurrentPath = InitialPath
    local ParentPath
    local LastSegment

    for _, segment in ipairs(path) do
        if CurrentPath[segment] then
            ParentPath = CurrentPath
            LastSegment = segment
            CurrentPath = CurrentPath[segment]
        elseif hardSet then
            CurrentPath[segment] = {}
            ParentPath = CurrentPath
            LastSegment = segment
            CurrentPath = CurrentPath[segment]
        else
            return false
        end
    end

    return true, CurrentPath, ParentPath, LastSegment
end

function DisplayStatUpdated(player: Player, statName: string, statValue: any)
    local LeaderstatsFolder = player:FindFirstChild("leaderstats")

    if not LeaderstatsFolder or not LeaderstatsFolder:IsA("Folder") then
        warn("Leaderstats folder missing or not a Folder instance for player: " .. tostring(player))
        return
    end

    local StatInstance = LeaderstatsFolder:FindFirstChild(statName)

    if not StatInstance or not StatInstance:IsA("NumberValue") then
        warn("Stat instance is not a valid value type for player: " .. tostring(player))
        return
    end

    StatInstance.Value = statValue
end

-- [ Public Functions ] --
function DataService.AddData(self: Module, player: Player, value: number, path: { string }): boolean
    if type(value) == "number" and (value ~= value) then
        warn("Invalid numeric value provided. Expected a number.")
        return false
    end

    local Success1, Data = self:GetData(player, path)

    if not Success1 or type(Data) ~= "number" then
        return false
    end

    local Success2 = self:SetData(player, Data+value, path)

    if not Success2 then
        return false
    else
        return true
    end
end

function DataService.SetData(self: Module, player: Player, value: any, path: { string }, hardSet: boolean?): boolean
    if type(value) == "number" and (value ~= value) then
        warn("Invalid numeric value provided. Expected a number.")
        return false
    end

    if type(path) ~= "table" then
        warn("Invalid path type specified. Please check path configuration.")
        return false
    end

    local Profile = GetProfile(player)

    local Success, _, ParentPath, LastSegment = ProcessPath(Profile.Data, path, hardSet)

    if not Success then
        return false
    else
        -- signal to clients that leaderstat is changed
        if table.find(DISPLAY_STATS, LastSegment) then
            DisplayStatUpdated(player, LastSegment, value)
        end
    
        ParentPath[LastSegment] = value
        return true
    end
end

function DataService.GetProfile(self: Module, player: Player): Profile
    return GetProfile(player)
end

function DataService.GetData(self: Module, player: Player, path: { string }): (boolean, any)
    if type(path) ~= "table" then
        warn("Invalid path type specified. Please check path configuration.")
        return false
    end
    
    local Profile = GetProfile(player)
    
    local Success, Data = ProcessPath(Profile.Data, path)

    if not Success then
        return false
    else
        return true, Data
    end
end

function DataService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end
    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function DataService.Start(self: Module)
    Remotes:Bind("GetData", function(player: Player, path: { string })
        return self:GetData(player, path)
    end)

    Players.PlayerAdded:Connect(PlayerAdded)  
end

return DataService :: Module