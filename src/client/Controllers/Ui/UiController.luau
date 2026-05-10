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
-- HANDLERS--
------------------------------
local MenuHandler = require("./Handlers/MenuHandler")

local UiController = {} :: ControllerTypes.UiController

function UiController:Init(controllers: ControllerTypes.ControllerTypes)
	MenuHandler:Init(controllers)
end

function UiController:Start()
	MenuHandler:Start()
end

------------------------------
-- MENU HANDLER STUFF--
------------------------------

function UiController:OpenMenu(menuName: string)
	local curMenu = MenuHandler:GetCurrentMenu()
	if curMenu and curMenu.Name == menuName then
		MenuHandler:CloseCurrentMenu()
		return
	end

	MenuHandler:OpenMenu(menuName)
end

function UiController:CloseCurrentMenu()
	MenuHandler:CloseCurrentMenu()
end

function UiController:GetCurrentMenu()
	return MenuHandler:GetCurrentMenu()
end

return UiController
