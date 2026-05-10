--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NetworkTypes = require("@self/Definitions")

local RemotesFolder: Folder

if RunService:IsServer() then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "NetworkRemotes"
	RemotesFolder.Parent = ReplicatedStorage
else
	RemotesFolder = ReplicatedStorage:WaitForChild("NetworkRemotes") :: Folder
end

local function getRemote<T>(name: string, className: "RemoteEvent" | "RemoteFunction"): T
	local existing = RemotesFolder:FindFirstChild(name)
	if existing then
		return existing :: any
	end

	if RunService:IsServer() then
		local remote = Instance.new(className)
		remote.Name = name
		remote.Parent = RemotesFolder
		return remote :: any
	else
		return RemotesFolder:WaitForChild(name) :: any
	end
end

return {
	
} :: NetworkTypes.Net
