--[=[
    @class DataService
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --
local ProfileStore = require("./Modules/ProfileStore")

-- [ Requires ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Remoting = require("Remoting")
local DebounceUtil = require("DebounceUtil")

-- [ Constants ] --
local KEY = "Dev_2"
local PROFILE_TEMPLATE = {
    Coins = 0,
    OwnedItems = {},
    Wheel = {
        Spins = 0,
        NextFreeSpin = 0,
    },
}
local DISPLAY_STATS = {"Coins"}

-- [ Variables ] --
local PlayerStore = ProfileStore.New(KEY, PROFILE_TEMPLATE)
local Profiles = {}
local Remotes = Remoting.new(ReplicatedStorage:WaitForChild("Remotes"), "DataService")

-- [ Module Table ] --
local DataService = {}

-- [ Types ] --
type ProfileData = {
    [string]: any
}
type Profile = ProfileStore.Profile<ProfileData>

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag
}
export type Module = typeof(DataService) & ModuleData

-- [ Private Functions ] --
local function GetProfile(player: Player): Profile
    while Profiles[player] == nil do
        task.wait(0.1)
    end

    return Profiles[player]
end

local function CreateLeaderstats(player: Player)
    local Profile = GetProfile(player)

    local FolderInstance = Instance.new("Folder", player)
    FolderInstance.Name = "leaderstats"

    for _, displayStat in DISPLAY_STATS do
        local value = Profile.Data[displayStat]
        if value and type(value) == "number" then
            local ValueInstance = Instance.new("IntValue", FolderInstance)
            ValueInstance.Name = displayStat
            ValueInstance.Value = value
        end
    end
end

local function PlayerAdded(player: Player)
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

local function ProcessPath(InitialPath: any, path: { string }, hardSet: boolean?): (boolean, any, any, any)
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
        print(Success)
        return false
    else
        ParentPath[LastSegment] = value
        return true
    end
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
    Players.PlayerAdded:Connect(PlayerAdded)

    Remotes:Bind("GetData", function(player: Player, path: { string })
        if not DebounceUtil:Try(tostring(player.UserId) .. "/DataService/GetData", 0.1) then
            return false
        else
            return self:GetData(player, path)
        end
    end)    
end

return DataService :: Module