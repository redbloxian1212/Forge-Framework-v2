--!strict

------------------------------
-- SERVICES --
------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

------------------------------
-- TYPES --
------------------------------
local ControllerTypes = require(ReplicatedStorage.Forge.Client.Types.ControllerTypes)
local PlayerDataType = require(ReplicatedStorage.Forge.Shared.Types.PlayerDataType)
type SubscriptionConnection = { Disconnect: (self: SubscriptionConnection) -> () }

------------------------------
-- DEPENDENCIES --
------------------------------
local Replica = require(ReplicatedStorage.ReplicaClient)
local Signal = require(ReplicatedStorage.Forge.Shared.Libs.Signal)

------------------------------
-- CONFIG --
------------------------------
local DataPaths = require(ReplicatedStorage.Forge.Shared.Config.DataPaths)

------------------------------
-- STATE --
------------------------------
local player = Players.LocalPlayer
local PlayerReplica: any = nil

------------------------------
-- UTILS --
------------------------------
local function ParsePath(path: string): { string }
	return string.split(path, ".")
end

------------------------------
-- MODULE --
------------------------------
local DataController = {} :: ControllerTypes.DataController
DataController.OnDataReady = Signal.new()
DataController.OnDataChanged = Signal.new()
DataController.DataPaths = DataPaths

function DataController:Init()
	-- *insert crickets sound*
end

function DataController:Start()
	Replica.OnNew("PlayerData", function(replica)
		if replica.Tags.Player ~= player then
			return
		end
		PlayerReplica = replica

		replica:OnChange(function(action, pathArray, newValue, oldValue)
			local dotPath = table.concat(pathArray, ".")

			self.OnDataChanged:Fire(dotPath, newValue, oldValue)
		end)

		self.OnDataReady:Fire(replica.Data)
	end)

	Replica.RequestData()
end

function DataController:GetData(): PlayerDataType.PlayerData?
	if not PlayerReplica then
		return nil
	end
	return PlayerReplica.Data
end

function DataController:GetStat(path: string): any
	local data = self:GetData()
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

function DataController:Subscribe(path: string, callback: (newValue: any) -> ()): SubscriptionConnection
	local connection = {}
	local active = true
	local signalConnection

	local function HookSignal()
		callback(self:GetStat(path))
		signalConnection = self.OnDataChanged:Connect(function(changedPath, newValue)
			if changedPath == path then
				callback(newValue)
			end
		end)
	end

	if PlayerReplica then
		HookSignal()
	else
		local readyConnection
		readyConnection = self.OnDataReady:Once(function()
			if not active then
				return
			end
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

return DataController
