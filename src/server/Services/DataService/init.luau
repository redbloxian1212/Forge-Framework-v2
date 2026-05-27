--!strict

------------------------------
-- SERVICES --
------------------------------
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------
-- DEPENDENCIES --
------------------------------
local ProfileManager = require(ServerScriptService.Forge.Core.ProfileManager)
local Replica = require(ReplicatedStorage.Forge.Shared.Vendor.ReplicaServer)
local Signal = require(ReplicatedStorage.Packages.Signal)

------------------------------
-- UTILITIES --
------------------------------
-- Required to compare array paths passed by reference
local function ArePathsEqual(pathA: { string }, pathB: { string }): boolean
	if #pathA ~= #pathB then
		return false
	end
	for i, key in ipairs(pathA) do
		if pathB[i] ~= key then
			return false
		end
	end
	return true
end

------------------------------
-- TYPES --
------------------------------
type SubscriptionConnection = { Disconnect: (self: SubscriptionConnection) -> () }
type PlayerData = ProfileManager.PlayerData

------------------------------
-- STATE --
------------------------------
local PlayerToken = Replica.Token("PlayerData")
local PlayerReplicas: { [Player]: typeof(Replica.New(...)) } = {}
local PlayerDataChanged: { [Player]: any } = {}

local DataService = {}
DataService.__index = DataService

export type DataService = typeof(setmetatable({}, DataService))

function DataService.create(): DataService
	return setmetatable({}, DataService)
end

function DataService.Init(self: DataService, container: any)
	self.DataPaths = require(ReplicatedStorage.Forge.Shared.Config.DataPaths)
	self.OnProfileLoaded = Signal.new()
	self.OnProfileUnloading = Signal.new()

	ProfileManager.Start()
end

function DataService.Start(self: DataService)
	ProfileManager.OnProfileLoaded:Connect(function(player: Player, profileData: PlayerData)
		local replica = Replica.New({
			Token = PlayerToken,
			Tags = { Player = player },
			Data = profileData,
		})

		PlayerDataChanged[player] = Signal.new()

		replica:Replicate()
		PlayerReplicas[player] = replica
		self.OnProfileLoaded:Fire(player, profileData)
	end)

	ProfileManager.OnProfileUnloading:Connect(function(player: Player)
		local replica = PlayerReplicas[player]
		if replica then
			replica:Destroy()
			PlayerReplicas[player] = nil
		end

		local signal = PlayerDataChanged[player]
		if signal then
			signal:DisconnectAll()
			PlayerDataChanged[player] = nil
		end
		self.OnProfileUnloading:Fire(player)
	end)
end

function DataService.GetData(_self: DataService, player: Player): PlayerData?
	local replica = PlayerReplicas[player]
	if not replica then
		warn(`[DataService] No replica found for {player.Name}`)
		return nil
	end
	return replica.Data
end

function DataService.GetStat(self: DataService, player: Player, path: { string }): any
	local data = self.GetData(self, player)
	if not data then
		return nil
	end

	local current = data
	for _, key in ipairs(path) do
		if type(current) ~= "table" then
			return nil
		end
		current = current[key]
	end
	return current
end

function DataService.SetData(_self: DataService, player: Player, path: { string }, value: any): boolean
	local replica = PlayerReplicas[player]
	local signal = PlayerDataChanged[player]
	if not replica or not signal then
		return false
	end

	replica:Set(path, value)
	signal:Fire(path, value)

	return true
end

function DataService.IncrementData(self: DataService, player: Player, path: { string }, delta: number): boolean
	local current = self.GetStat(self, player, path) or 0
	if type(current) ~= "number" then
		warn(`[DataService] Cannot increment non-number at '{table.concat(path, ".")}' for {player.Name}`)
		return false
	end

	return self.SetData(self, player, path, current + delta)
end

function DataService.Subscribe(
	self: DataService,
	player: Player,
	path: { string },
	callback: (newValue: any) -> ()
): SubscriptionConnection
	local active = true
	local signalConnection: any

	local function HookSignal()
		callback(DataService.GetStat(self, player, path))
		signalConnection = PlayerDataChanged[player]:Connect(function(changedPath: { string }, newValue: any)
			if ArePathsEqual(changedPath, path) then
				callback(newValue)
			end
		end)
	end

	if PlayerDataChanged[player] then
		HookSignal()
	else
		local profileConnection: any
		profileConnection = self.OnProfileLoaded:Connect(function(loadedPlayer: Player)
			if not active then
				profileConnection:Disconnect()
				return
			end
			if loadedPlayer ~= player then
				return
			end

			profileConnection:Disconnect()
			HookSignal()
		end)
	end

	local connection: SubscriptionConnection = {
		Disconnect = function()
			active = false
			if signalConnection then
				signalConnection:Disconnect()
			end
		end,
	}

	return connection
end

return DataService
