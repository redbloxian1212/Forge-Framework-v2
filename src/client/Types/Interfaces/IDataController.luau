--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SignalTypes = require(ReplicatedStorage.Forge.Shared.Types.SignalType)
local PlayerDataType = require(ReplicatedStorage.Forge.Shared.Types.PlayerDataType)

export type IDataController = {
	OnDataReady: SignalTypes.Signal<PlayerDataType.PlayerData>,
	OnDataChanged: SignalTypes.Signal<string, any, any>,

	Init: (self: IDataController, controllers: any) -> (),
	Start: (self: IDataController) -> (),

	GetData: (self: IDataController) -> PlayerDataType.PlayerData?,
	GetStat: (self: IDataController, path: string) -> any,
	Subscribe: (self: IDataController, path: string, callback: (newValue: any) -> ()) -> (),
}

return {}
