--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Forge.Shared.Network)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Template = {}
Template.__index = Template

type Template = typeof(setmetatable({}, Template))

function Template.new(tool: Tool): Template
	assert(typeof(tool) == "Instance" and tool:IsA("Tool"), "bad tool!")

	local self = setmetatable({}, Template) :: Template
	self._toolInstance = tool
	self._trove = Trove.new()

	self._trove:Add(
		tool.Equipped:Connect(function()
			self:OnEquipped()
		end)
	)

	self._trove:Add(
		tool.Unequipped:Connect(function()
			self:OnUnequipped()
		end)
	)

	self._trove:Add(
		tool.Activated:Connect(function()
			self:OnActivated()
		end)
	)

	return self
end

--// Equip Logic
function Template.OnEquipped(self: Template)
	print(self._toolInstance, "was equipped!")
end

--// Unequip Logic
function Template.OnUnequipped(self: Template)
	print(self._toolInstance, "was unequipped!")
end

function Template.OnActivated(self: Template)
	print(self._toolInstance, "was activated!")
end

function Template.Destroy(self: Template)
    self._trove:Clean()
end

return Template
