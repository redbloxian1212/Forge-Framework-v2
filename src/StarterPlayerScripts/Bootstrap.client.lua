--!strict

------------------------------
-- SERVICES --
------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------
-- TYPES --
------------------------------
local Types = ReplicatedStorage.Forge.Client.Types
local ControllerTypes = require(Types.ControllerTypes)

------------------------------
-- CONTROLLER LIFECYCLE --
------------------------------
local ControllersFolder = ReplicatedStorage.Forge.Client.Controllers
local ControllerRegistry = require(ReplicatedStorage.Forge.Client.Core.ControllerRegistry)

local Controllers: ControllerTypes.ControllerTypes = {
	DataController = require(ControllersFolder.Data.DataController),
	UiController = require(ControllersFolder.Ui.UiController),
}

ControllerRegistry.Load(Controllers)
