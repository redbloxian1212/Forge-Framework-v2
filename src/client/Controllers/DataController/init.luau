--!strict

------------------------------
-- SERVICES --
------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

------------------------------
-- TYPES --
------------------------------
local Container = require(ReplicatedStorage.Forge.Shared.Core.Container)
type SubscriptionConnection = { Disconnect: (self: SubscriptionConnection) -> () }
type PlayerData = typeof(require(ReplicatedStorage.Forge.Shared.Config.PlayerDataTemplate))

------------------------------
-- DEPENDENCIES --
------------------------------
local Replica = require(ReplicatedStorage.Forge.Shared.Vendor.ReplicaClient)
local Signal = require(ReplicatedStorage.Packages.Signal)

------------------------------
-- CONFIG --
------------------------------
local DataPaths = require(ReplicatedStorage.Forge.Shared.Config.DataPaths)

------------------------------
-- UTILITIES --
------------------------------
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
-- MODULE --
------------------------------
local DataController = {}
DataController.__index = DataController

export type DataController = typeof(setmetatable(
	{} :: {
		_playerReplica: any,
		OnDataReady: typeof(Signal.new()),
		OnDataChanged: typeof(Signal.new()),
		DataPaths: typeof(DataPaths),
	},
	DataController
))

function DataController.create(): DataController
	return setmetatable({
		_playerReplica = nil :: any,
		OnDataReady = Signal.new(),
		OnDataChanged = Signal.new(),
		DataPaths = DataPaths,
	}, DataController)
end

function DataController.Init(self: DataController, container: Container.ContainerType)
	self.DataPaths = require(ReplicatedStorage.Forge.Shared.Config.DataPaths)
end

function DataController.Start(self: DataController)
	local player = Players.LocalPlayer

	Replica.OnNew("PlayerData", function(replica)
		if replica.Tags.Player ~= player then
			return
		end
		self._playerReplica = replica

		replica:OnChange(function(action, pathArray, newValue, oldValue)
			self.OnDataChanged:Fire(pathArray, newValue, oldValue)
		end)

		self.OnDataReady:Fire(replica.Data)
	end)

	Replica.RequestData()
end

function DataController.GetData(_self: DataController): PlayerData?
	if not _self._playerReplica then
		return nil
	end
	return _self._playerReplica.Data
end

function DataController.GetStat(self: DataController, path: { string }): any
	local data = self.GetData(self)
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

function DataController.Subscribe(
	self: DataController,
	path: { string },
	callback: (newValue: any) -> ()
): SubscriptionConnection
	local active = true
	local signalConnection: any

	local function HookSignal()
		callback(DataController.GetStat(self, path))
		signalConnection = self.OnDataChanged:Connect(function(changedPath: { string }, newValue: any)
			if ArePathsEqual(changedPath, path) then
				callback(newValue)
			end
		end)
	end

	if self._playerReplica then
		HookSignal()
	else
		local readyConnection: any
		readyConnection = self.OnDataReady:Connect(function()
			if not active then
				readyConnection:Disconnect()
				return
			end
			readyConnection:Disconnect()
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

return DataController
