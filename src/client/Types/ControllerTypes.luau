local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Interface References
local Interfaces = ReplicatedStorage.Forge.Client.Types.Interfaces
local IDataController = require(Interfaces.IDataController)
local IUiController = require(Interfaces.IUiController)

export type ControllerTypes = {
	DataController: DataController,
	UiController: UiController,
}

export type DataController = IDataController.IDataController
export type UiController = IUiController.IUiController

return {}
