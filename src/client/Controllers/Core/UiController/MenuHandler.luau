------------------------------
-- SERVICES --
------------------------------
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

------------------------------
-- SOUND REFS --
------------------------------
local UiSfx = SoundService:WaitForChild("Sfx").Ui

------------------------------
-- PRIVATE --
------------------------------
local function setBlur(blurEffect: BlurEffect, blurSize: number, duration: number)
	TweenService:Create(blurEffect, TweenInfo.new(duration), { Size = blurSize }):Play()
end

local function setCamFov(fov: number, duration: number)
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(duration), { FieldOfView = fov }):Play()
end

local OPEN_TWEEN_INFO = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local SLIDE_OFFSET = UDim2.fromScale(0, 0.5)

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
	if self._blurEffect then
		-- guard against double-Start leaking a BlurEffect
		self._blurEffect:Destroy()
	end

	self._originalPositions = {}

	for _, menu in self._menuFolder:GetChildren() do
		if not (menu:IsA("Frame") or menu:IsA("ImageLabel")) then
			warn(`[MenuHandler] Menu '{menu.Name}' is not a Frame or an ImageLabel!`)
			continue
		end

		self._originalPositions[menu] = menu.Position

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

	local menu = self._menuFolder:FindFirstChild(menuName)
	if not (menu and (menu:IsA("Frame") or menu:IsA("ImageLabel"))) then
		warn(`[MenuHandler] Menu '{menuName}' not found!`)
		return
	end

	self._currentMenu = menu

	local uiScale = menu:FindFirstChildOfClass("UIScale") :: UIScale
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Parent = menu
	end

	local originalPos = self._originalPositions[menu]

	uiScale.Scale = 0
	menu.Position = originalPos + SLIDE_OFFSET
	menu.Visible = true

	TweenService:Create(menu, OPEN_TWEEN_INFO, { Position = originalPos }):Play()
	TweenService:Create(uiScale, OPEN_TWEEN_INFO, { Scale = 1 }):Play()
	setBlur(self._blurEffect :: BlurEffect, 20, 0.25)
	setCamFov(65, 0.2)

	UiSfx.Pop:Play()
end

function MenuHandler.CloseCurrentMenu(self: MenuHandler)
	if not self._currentMenu then
		return
	end

	local menuToClose = self._currentMenu
	self._currentMenu = nil

	local uiScale = menuToClose:FindFirstChildOfClass("UIScale") :: UIScale
	local originalPos = self._originalPositions[menuToClose]

	local tween = TweenService:Create(menuToClose, CLOSE_TWEEN_INFO, { Position = originalPos + SLIDE_OFFSET })
	TweenService:Create(uiScale, CLOSE_TWEEN_INFO, { Scale = 0 }):Play()
	tween:Play()
	setBlur(self._blurEffect :: BlurEffect, 0, 0.25)
	setCamFov(70, 0.2)

	tween.Completed:Once(function()
		if self._currentMenu ~= menuToClose then
			menuToClose.Visible = false
			menuToClose.Position = originalPos
		end
	end)

	UiSfx.Whoosh:Play()
end

function MenuHandler.GetCurrentMenu(self: MenuHandler)
	return self._currentMenu
end

return MenuHandler
