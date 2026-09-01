------------------------------
-- SERVICES --
------------------------------
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Sounds = SoundService:WaitForChild("Sfx").Ui

------------------------------
-- CONFIG --
------------------------------
local HOVER_SCALE = 1.1
local CLICK_SCALE = 0.9
local NORMAL_SCALE = 1
local ICON_RISE_PX = -8 -- pixels to rise on hover
local ICON_TILT_DEG = 12 -- rotation on hover

------------------------------
-- CONSTANTS --
------------------------------
local TWEEN_INFO = TweenInfo.new(0.185, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
local ICON_TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

local function tweenScale(uiScale: UIScale, target: number)
	TweenService:Create(uiScale, TWEEN_INFO, { Scale = target }):Play()
end

local function tweenIcon(icon: ImageLabel, targetPos: UDim2, targetRot: number)
	TweenService:Create(icon, ICON_TWEEN_INFO, {
		Position = targetPos,
		Rotation = targetRot,
	}):Play()
end

local AnimatedButton = {}
AnimatedButton.__index = AnimatedButton
AnimatedButton.Tag = "AnimatedButton"

function AnimatedButton.new(instance: Instance)
	local button = instance :: GuiButton

	local self = setmetatable({}, AnimatedButton)
	self._button = button
	self._connections = {}

	local uiScale = button:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", button)
	self._uiScale = uiScale

	-- Icon setup
	local icon = button:FindFirstChild("Icon")
	local iconOriginPos: UDim2?
	local iconOriginRot: number?

	if icon and icon:IsA("ImageLabel") then
		iconOriginPos = icon.Position
		iconOriginRot = icon.Rotation
	end

	local function hoverIcon()
		if not icon or not iconOriginPos then
			return
		end
		tweenIcon(icon, iconOriginPos + UDim2.fromOffset(0, ICON_RISE_PX), (iconOriginRot :: number) + ICON_TILT_DEG)
	end

	local function resetIcon()
		if not icon or not iconOriginPos then
			return
		end
		tweenIcon(icon, iconOriginPos, iconOriginRot :: number)
	end

	table.insert(
		self._connections,
		button.MouseEnter:Connect(function()
			tweenScale(uiScale, HOVER_SCALE)
			hoverIcon()
			Sounds.hover:Play()
		end)
	)

	table.insert(
		self._connections,
		button.MouseLeave:Connect(function()
			tweenScale(uiScale, NORMAL_SCALE)
			resetIcon()
		end)
	)

	table.insert(
		self._connections,
		button.MouseButton1Down:Connect(function()
			tweenScale(uiScale, CLICK_SCALE)
			Sounds.click:Play()
		end)
	)

	table.insert(
		self._connections,
		button.MouseButton1Up:Connect(function()
			tweenScale(uiScale, NORMAL_SCALE)
		end)
	)

	return self
end

function AnimatedButton:Destroy()
	for _, c in self._connections do
		c:Disconnect()
	end
	table.clear(self._connections)

	if self._uiScale then
		self._uiScale.Scale = NORMAL_SCALE
	end
end

return AnimatedButton
