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
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

------------------------------
-- LOCAL --
------------------------------
local player = Players.LocalPlayer
local playerGui = player.PlayerGui

------------------------------
-- UI REFERENCES --
------------------------------
local mainGui = playerGui:WaitForChild("Main")
local menuFolder = mainGui:WaitForChild("Menus")

------------------------------
-- STATE --
------------------------------
local origMenuSizes: { [string]: UDim2 } = {}
local currentMenu: Frame?

local blurEffect: BlurEffect

local function setBlur(blurSize: number, duration: number)
	local tween = TweenService:Create(blurEffect, TweenInfo.new(duration), { Size = blurSize })
	tween:Play()
end

local function setCamFov(fov: number, duration: number)
	local tween = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(duration), { FieldOfView = fov })
	tween:Play()
end

local MenuHandler = {}

function MenuHandler:Init(_controllers) end

function MenuHandler:Start()
	for _, menu in menuFolder:GetChildren() do
		if not (menu:IsA("Frame") or menu:IsA("ImageLabel")) then
			warn(`[MenuHandler] Menu '{menu.Name}' is not a Frame or an ImageLabel!`)
			continue
		end

		assert(not origMenuSizes[menu.Name], `Menu '{menu.Name}' already initialized`)

		origMenuSizes[menu.Name] = menu.Size
	end

	blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "MenuBlur"
	blurEffect.Size = 0
	blurEffect.Parent = game.Lighting
end

function MenuHandler:OpenMenu(menuName: string)
	if currentMenu then
		self:CloseCurrentMenu()
	end

	local menu = menuFolder:FindFirstChild(menuName)
	if not menu then
		warn(`[MenuHandler] Menu '{menuName}' not found!`)
		return
	end

	currentMenu = menu
	local origSize = origMenuSizes[menuName]

	-- Start small at its current anchored location
	menu.Size = UDim2.fromScale(0, 0)
	menu.Visible = true

	TweenService:Create(menu, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = origSize })
		:Play()
	setBlur(20, 0.25)
	setCamFov(45, 0.2)
end

function MenuHandler:CloseCurrentMenu()
	if not currentMenu then
		return
	end

	local menuToClose = currentMenu
	currentMenu = nil -- Instantly clear state so it doesn't block opening another menu

	-- Tween back to 0
	local tween = TweenService:Create(
		menuToClose,
		TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Size = UDim2.fromScale(0, 0) }
	)
	tween:Play()
	setBlur(0, 0.25)
	setCamFov(70, 0.2)

	tween.Completed:Once(function()
		-- Only hide if the user didn't instantly reopen this exact menu during the animation
		if currentMenu ~= menuToClose then
			menuToClose.Visible = false
		end
	end)
end

function MenuHandler:GetCurrentMenu()
	return currentMenu
end

return MenuHandler
