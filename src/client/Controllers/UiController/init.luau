--!strict

------------------------------
-- SERVICES --
------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------
-- TYPES --
------------------------------
local ClientTypes = ReplicatedStorage.Forge.Client.Types
local ControllerTypes = require(ClientTypes.ControllerTypes)

------------------------------
-- DEPENDENCIES --
------------------------------
local Controllers: ControllerTypes.ControllerTypes

------------------------------
-- HANDLERS --
------------------------------
local MenuHandler = require("@self/MenuHandler")
local HudHandler = require("@self/HudHandler")

local UiController = {} :: ControllerTypes.UiController

function UiController:Init(controllers)
	Controllers = controllers

	MenuHandler:Init(controllers)
	HudHandler:Init(controllers)
end

function UiController:Start()
	MenuHandler:Start()
	HudHandler:Start()
end

function UiController:OpenMenu(menuName: string)
	local curMenu = MenuHandler:GetCurrentMenu()
	if curMenu and curMenu.Name == menuName then
		MenuHandler:CloseCurrentMenu()
		return
	end

	Controllers.TrollController:CloseMenu()
	MenuHandler:OpenMenu(menuName)
end

function UiController:CloseCurrentMenu()
	MenuHandler:CloseCurrentMenu()
end

function UiController:GetCurrentMenu()
	return MenuHandler:GetCurrentMenu()
end

return UiController
