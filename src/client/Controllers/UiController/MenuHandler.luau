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
	local tween = TweenService:Create(blurEffect, TweenInfo.new(duration), { Size = blurSize })
	tween:Play()
end

local function setCamFov(fov: number, duration: number)
	local tween = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(duration), { FieldOfView = fov })
	tween:Play()
end

local MenuHandler = {}
MenuHandler.__index = MenuHandler

export type MenuHandler = typeof(setmetatable(
	{} :: {
		_menuFolder: Instance,
		_origMenuSizes: { [string]: UDim2 },
		_currentMenu: Frame?,
		_blurEffect: BlurEffect?,
	},
	MenuHandler
))

function MenuHandler.create(menuFolder: Instance)
	return setmetatable({
		_menuFolder = menuFolder,
		_origMenuSizes = {} :: { [string]: UDim2 },
		_currentMenu = nil :: Frame?,
		_blurEffect = nil :: BlurEffect?,
	}, MenuHandler)
end

function MenuHandler.Start(self: MenuHandler)
	for _, menu in self._menuFolder:GetChildren() do
		if not (menu:IsA("Frame") or menu:IsA("ImageLabel")) then
			warn(`[MenuHandler] Menu '{menu.Name}' is not a Frame or an ImageLabel!`)
			continue
		end

		assert(not self._origMenuSizes[menu.Name], `Menu '{menu.Name}' already initialized`)

		self._origMenuSizes[menu.Name] = menu.Size
	end

	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "MenuBlur"
	blurEffect.Size = 0
	blurEffect.Parent = game.Lighting
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

	self._currentMenu = menu :: Frame
	local origSize = self._origMenuSizes[menuName]

	-- Start small at its current anchored location
	menu.Size = UDim2.fromScale(0, 0)
	menu.Visible = true

	TweenService:Create(menu, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = origSize })
		:Play()
	setBlur(self._blurEffect :: BlurEffect, 20, 0.25)
	setCamFov(45, 0.2)
end

function MenuHandler.CloseCurrentMenu(self: MenuHandler)
	if not self._currentMenu then
		return
	end

	local menuToClose = self._currentMenu
	self._currentMenu = nil -- Instantly clear state so it doesn't block opening another menu

	-- Tween back to 0
	local tween = TweenService:Create(
		menuToClose,
		TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Size = UDim2.fromScale(0, 0) }
	)
	tween:Play()
	setBlur(self._blurEffect :: BlurEffect, 0, 0.25)
	setCamFov(70, 0.2)

	tween.Completed:Once(function()
		-- Only hide if the user didn't instantly reopen this exact menu during the animation
		if self._currentMenu ~= menuToClose then
			menuToClose.Visible = false
		end
	end)
end

function MenuHandler.GetCurrentMenu(self: MenuHandler)
	return self._currentMenu
end

return MenuHandler
