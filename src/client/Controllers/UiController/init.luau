local Container = require(game:GetService("ReplicatedStorage").Forge.Shared.Core.Container)

------------------------------
-- HANDLERS --
------------------------------
local MenuHandler = require("@self/MenuHandler")

local UiController = {}
UiController.__index = UiController

export type UiController = typeof(setmetatable(
	{} :: {
		_menuHandler: MenuHandler.MenuHandler,
	},
	UiController
))

function UiController.create()
	return setmetatable(
		{} :: {
			_menuHandler: MenuHandler.MenuHandler,
		},
		UiController
	)
end

function UiController.Init(self: UiController, container: Container.ContainerType)
	local player = game:GetService("Players").LocalPlayer
	local menuFolder = player.PlayerGui:WaitForChild("Main"):WaitForChild("Menus")
	self._menuHandler = MenuHandler.create(menuFolder)
end

function UiController.Start(self: UiController)
	self._menuHandler:Start()
end

function UiController.OpenMenu(self: UiController, menuName: string)
	local curMenu = self._menuHandler:GetCurrentMenu()
	if curMenu and curMenu.Name == menuName then
		self._menuHandler:CloseCurrentMenu()
		return
	end

	self._menuHandler:OpenMenu(menuName)
end

function UiController.CloseCurrentMenu(self: UiController)
	self._menuHandler:CloseCurrentMenu()
end

function UiController.GetCurrentMenu(self: UiController)
	return self._menuHandler:GetCurrentMenu()
end

return UiController
