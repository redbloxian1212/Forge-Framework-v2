--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SignalTypes = require(ReplicatedStorage.Forge.Shared.Types.SignalType)
local PlayerDataType = require(ReplicatedStorage.Forge.Shared.Types.PlayerDataType)

export type IUiController = {
	Init: (self: IUiController, controllers: any) -> (),
	Start: (self: IUiController) -> (),

	OpenMenu: (self: IUiController, menuName: string) -> (),
	CloseCurrentMenu: (self: IUiController) -> (),
	GetCurrentMenu: (self: IUiController) -> Frame?,
}

return {}
