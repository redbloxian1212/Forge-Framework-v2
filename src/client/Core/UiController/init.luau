local Container = require(game:GetService("ReplicatedStorage").Forge.Shared.Core.Container)

------------------------------
-- HANDLERS --
------------------------------
local MenuHandler = require("@self/MenuHandler")

local UiController = {}
UiController.__index = UiController

export type UiController = typeof(setmetatable({}, UiController))

function UiController.create(): UiController
	return setmetatable({}, UiController)
end

function UiController.Init(self: UiController, container: Container.ContainerType)
	self._isMenuOpen = false
	self._menuStateSubscribers = {} :: { (menuState: boolean) -> () }

	local player = game:GetService("Players").LocalPlayer
	local menuFolder = player.PlayerGui:WaitForChild("Main"):WaitForChild("Menus")
	self._menuHandler = MenuHandler.create()
	self._menuHandler:Init(menuFolder)
end

function UiController.Start(self: UiController)
	self._menuHandler:Start()
end

--[=[
	Updates the menu state and calls all subscribers
]=]
function UiController._updateMenuState(self: UiController)
	local menuOpen = self._menuHandler:GetCurrentMenu() ~= nil and true or false

	self._isMenuOpen = menuOpen

	--// calling.. the callbacks
	for _, cb in self._menuStateSubscribers do
		cb(menuOpen)
	end
end

function UiController.OpenMenu(self: UiController, menuName: string)
	local curMenu = self._menuHandler:GetCurrentMenu()
	if curMenu and curMenu.Name == menuName then
		self:CloseCurrentMenu()
		return
	end

	self._menuHandler:OpenMenu(menuName)
	self:_updateMenuState()
end

function UiController.CloseCurrentMenu(self: UiController)
	self._menuHandler:CloseCurrentMenu()
	self:_updateMenuState()
end

function UiController.GetCurrentMenu(self: UiController)
	return self._menuHandler:GetCurrentMenu()
end

--[=[
	Subscribes to menu open/close state changes,
	immediately fires callback with current state,
	then again on every change.
	
	Returns a function to unsubscribe
]=]
function UiController.OnMenuStateChanged(self: UiController, callback: (isMenuOpen: boolean) -> ())
	callback(self._isMenuOpen)
	table.insert(self._menuStateSubscribers, callback)

	return function()
		local index = table.find(self._menuStateSubscribers, callback)
		if index then
			table.remove(self._menuStateSubscribers, index)
		end
	end
end

return UiController
