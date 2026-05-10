--!strict

------------------------------
-- SERVICES --
------------------------------
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------
-- TYPES --
------------------------------
local ServiceTypes = require(ServerScriptService.Forge.Types.ServiceTypes)
local PlayerDataType = require(ReplicatedStorage.Forge.Shared.Types.PlayerDataType)
export type SubscriptionConnection = { Disconnect: (self: SubscriptionConnection) -> () }

------------------------------
-- DEPENDENCIES --
------------------------------
local ProfileManager = require(ServerScriptService.Forge.Core.ProfileManager)
local Replica = require(ServerScriptService.Forge.Libs.ReplicaServer)
local Signal = require(ReplicatedStorage.Forge.Shared.Libs.Signal)

------------------------------
-- STATE --
------------------------------
local PlayerToken = Replica.Token("PlayerData")
local PlayerReplicas: { [Player]: typeof(Replica.New(...)) } = {}
local PlayerDataChanged: { [Player]: any } = {}

--[[
	Replica.New({
			Token = PlayerToken,
			Tags = { Player = player },
			Data = profileData,
		})
]]

------------------------------
-- UTILS --
------------------------------
local function ParsePath(path: string): { string }
	return string.split(path, ".")
end

------------------------------
-- MODULE --
------------------------------
local DataService = {} :: ServiceTypes.DataService
DataService.OnProfileLoaded = Signal.new()
DataService.OnProfileUnloading = Signal.new()

function DataService:Init(_services: ServiceTypes.ServiceTypes)
	ProfileManager.Start()
end

function DataService:Start()
	ProfileManager.OnProfileLoaded:Connect(function(player: Player, profileData)
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

		if PlayerDataChanged[player] then
			PlayerDataChanged[player]:DisconnectAll()
			PlayerDataChanged[player] = nil
		end
		self.OnProfileUnloading:Fire(player)
	end)
end

function DataService:GetData(player: Player): PlayerDataType.PlayerData?
	local replica = PlayerReplicas[player]
	if not replica then
		warn(`[DataService] No replica found for {player.Name}`)
		return nil
	end
	return replica.Data
end

function DataService:GetStat(player: Player, path: string): any
	local data = self:GetData(player)
	if not data then
		return nil
	end

	local current = data
	for _, key in ipairs(ParsePath(path)) do
		if type(current) ~= "table" then
			return nil
		end
		current = current[key]
	end
	return current
end

function DataService:SetData(player: Player, path: string, value: any): boolean
	local replica = PlayerReplicas[player]
	local signal = PlayerDataChanged[player]
	if not replica or not signal then
		return false
	end

	-- Perform the actual write to Replica
	replica:Set(ParsePath(path), value)

	-- Manually fire the signal for server-side subscribers
	signal:Fire(path, value)

	return true
end

function DataService:IncrementData(player: Player, path: string, delta: number): boolean
	warn("inc data")
	local current = self:GetStat(player, path) or 0
	if type(current) ~= "number" then
		warn(`[DataService] Cannot increment non-number at '{path}' for {player.Name}`)
		return false
	end

	-- SetData now handles the signal firing
	return self:SetData(player, path, current + delta)
end

function DataService:Subscribe(player: Player, path: string, callback: (newValue: any) -> ()): SubscriptionConnection
	local connection = {}
	local active = true
	local signalConnection

	local function HookSignal()
		callback(self:GetStat(player, path))
		signalConnection = PlayerDataChanged[player]:Connect(function(changedPath: string, newValue: any)
			if changedPath == path then
				callback(newValue)
			end
		end)
	end

	if PlayerDataChanged[player] then
		HookSignal()
	else
		local profileConnection
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

	function connection:Disconnect()
		active = false
		if signalConnection then
			signalConnection:Disconnect()
		end
	end

	return connection
end

return DataService
