--[=[
	@class AssetProvider
	@description A utility module for retrieving and cloning assets from the ReplicatedStorage Assets folder
]=]

-- [ Roblox Services ] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ Imports ] --

-- [ Requires ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Types ] --

-- [ Variables ] --
local AssetsFolder = ReplicatedStorage:WaitForChild("Assets") :: Folder

-- [ Module Table ] --
local AssetProvider = {}

export type Module = typeof(AssetProvider)

-- [ Private Functions ] --

-- [ Public Functions ] --

--[=[
	Gets an asset from the AssetsFolder by following the provided path

	@param self Module - The AssetProvider module
	@param path {string} - Array of path segments to traverse
	@return Instance - The cloned asset found at the specified path
]=]
function AssetProvider.Get(self: Module, path: { string })
    local CurrentPath: any = AssetsFolder

    for _, segment in path do
        local NewPath = CurrentPath:FindFirstChild(segment)

        if not NewPath then
            error(("[AssetProvider] Could not find asset at segment '%s' in path: %s"):format(
                segment,
                table.concat(path, "/")
            ))
        end

        CurrentPath = NewPath
    end

    local Asset = CurrentPath:Clone()

    return Asset
end

return AssetProvider :: Module