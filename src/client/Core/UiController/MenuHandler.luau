--[[
	MenuHandler.luau
	
	@desc: Handles visibility, animation and effects for navigating on different menus in the game
	
	Behavior:
	- By default, if it is asked to open a menu that is currently open, it will close it
	- Only one menu visible at all times
	- When opening a menu, it closes the current one, if there are any
	- If you want a button to close the menu, just leave "TargetMenu" completely empty
]]

------------------------------
-- SERVICES --
------------------------------
local TweenService = game:GetService("TweenService")

------------------------------
-- PRIVATE --
------------------------------
local function setBlur(blurEffect: BlurEffect, blurSize: number, duration: number)
	TweenService:Create(blurEffect, TweenInfo.new(duration), { Size = blurSize }):Play()
end

local function setCamFov(fov: number, duration: number)
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(duration), { FieldOfView = fov }):Play()
end

local MenuHandler = {}
MenuHandler.__index = MenuHandler

export type MenuHandler = typeof(setmetatable({}, MenuHandler))

function MenuHandler.create()
	return setmetatable({}, MenuHandler)
end

function MenuHandler.Init(self: MenuHandler, menuFolder: Instance)
	assert(typeof(menuFolder) == "Instance" and menuFolder:IsA("Folder"), "bad menuFolder!")

	self._menuFolder = menuFolder
end

function MenuHandler.Start(self: MenuHandler)
	for _, menu in self._menuFolder:GetChildren() do
		if not (menu:IsA("Frame") or menu:IsA("ImageLabel")) then
			warn(`[MenuHandler] Menu '{menu.Name}' is not a Frame or an ImageLabel!`)
			continue
		end

		if menu:FindFirstChildOfClass("UIScale") then
			continue
		end

		local uiScale = Instance.new("UIScale")
		uiScale.Scale = 0
		uiScale.Parent = menu
		menu.Visible = false
	end

	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "MenuBlur"
	blurEffect.Size = 0
	blurEffect.Parent = game:GetService("Lighting")
	self._blurEffect = blurEffect
end

function MenuHandler.OpenMenu(self: MenuHandler, menuName: string)
	if self._currentMenu then
		self:CloseCurrentMenu()
	end

	local menu = self._menuFolder:FindFirstChild(menuName) :: Frame
	if not menu then
		warn(`[MenuHandler] Menu '{menuName}' not found!`)
		return
	end

	self._currentMenu = menu

	local uiScale = menu:FindFirstChildOfClass("UIScale") :: UIScale

	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Parent = menu
	end

	uiScale.Scale = 0
	menu.Visible = true

	TweenService:Create(uiScale, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 })
		:Play()
	setBlur(self._blurEffect :: BlurEffect, 20, 0.25)
	setCamFov(65, 0.2)
end

function MenuHandler.CloseCurrentMenu(self: MenuHandler)
	if not self._currentMenu then
		return
	end

	local menuToClose = self._currentMenu
	self._currentMenu = nil

	local uiScale = menuToClose:FindFirstChildOfClass("UIScale") :: UIScale
	local tween =
		TweenService:Create(uiScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 })
	tween:Play()
	setBlur(self._blurEffect :: BlurEffect, 0, 0.25)
	setCamFov(70, 0.2)

	tween.Completed:Once(function()
		if self._currentMenu ~= menuToClose then
			menuToClose.Visible = false
		end
	end)
end

function MenuHandler.GetCurrentMenu(self: MenuHandler)
	return self._currentMenu
end

return MenuHandler
