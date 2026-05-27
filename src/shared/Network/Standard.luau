--!strict

export type Net = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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
		local remote = RemotesFolder:WaitForChild(name, 10)
		if not remote then
			error(`[Net] Remote "{name}" not found after 10s — was it created on the server?`)
		end
		return remote :: any
	end
end

return {} :: Net
