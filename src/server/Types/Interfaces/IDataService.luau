--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SignalTypes = require(ReplicatedStorage.Forge.Shared.Types.SignalType)
local PlayerDataType = require(ReplicatedStorage.Forge.Shared.Types.PlayerDataType)

export type IDataService = {
	OnProfileLoaded: SignalTypes.Signal<Player, PlayerDataType.PlayerData>,
	OnProfileUnloading: SignalTypes.Signal<Player>,

	Init: (self: IDataService, services: any) -> (),
	Start: (self: IDataService) -> (),

	GetReplica: (self: IDataService, player: Player) -> any,
	GetData: (self: IDataService, player: Player) -> PlayerDataType.PlayerData?,
	GetStat: (self: IDataService, player: Player, path: string) -> any,
	SetData: (self: IDataService, player: Player, path: string, value: any) -> boolean,
	IncrementData: (self: IDataService, player: Player, path: string, delta: number) -> boolean,
	Subscribe: (self: IDataService, player: Player, path: string, callback: (newValue: any) -> ()) -> (),
}

return {}
