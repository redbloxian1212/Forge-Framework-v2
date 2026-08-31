--[=[
	@class ToolController

	@desc
	- Detects player tools (local player)
	- Handles binding of logic of the tools and their lifecycle
	
	@behaviour
	- Any tool added to the player is detected,
	checkcs if ToolClassId attribute exists and binds the class to the tool if found.

	@notes
	Config can be found in ReplicatedStorage.Forge.Config.ToolConfig.
	We do not have a Service counterpart for this yet...
]=]

------------------------------
-- SERVICES --
------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

------------------------------
-- INTERNALS --
------------------------------
local ToolClasses = script.ToolClasses

------------------------------
-- DEPENDENCIES --
------------------------------
local Trove = require(ReplicatedStorage.Packages.Trove)
local Observers = require(ReplicatedStorage.Packages.Observers)

------------------------------
-- LOCAL --
------------------------------
local player = Players.LocalPlayer

------------------------------
-- TYPES --
------------------------------
local Container = require(game:GetService("ReplicatedStorage").Forge.Shared.Core.Container)
type ToolObject = {
	Destroy: (self: ToolObject) -> (),
}

type ToolClass = {
	new: (tool: Tool) -> ToolObject,
}

local ToolController = {}
ToolController.__index = ToolController

export type ToolController = typeof(setmetatable({}, ToolController))

function ToolController.create()
	return setmetatable({}, ToolController)
end

function ToolController.Init(self: ToolController, container: Container.ContainerType)
	self._registry = {} :: { [Tool]: ToolObject }
	self._ancestryConns = {} :: { [Tool]: RBXScriptConnection }
	self._currentBackpack = nil :: Backpack?
	self._trove = Trove.new()
end

function ToolController.Start(self: ToolController)
	Observers.observeLocalCharacter(function(character: Model)
		self._trove:Clean()
		self._ancestryConns = {}
		
		self._currentBackpack = player:WaitForChild("Backpack", 3)
		if not self._currentBackpack then
			warn(`[ToolController] Could not get backpack!`)
			return
		end
		
		self:_refresh(self._currentBackpack, character)

		return function()
			self:_clearRegistry()
			self._currentBackpack = nil
		end
	end)
end

--[=[
	Updates the observed backpack and binds logic to any tools that are present in the backpack and character.
]=]
function ToolController._refresh(self: ToolController, backpack: Backpack, character: Model)
	--// Observe new tools being added to the backpack
	self._trove:Add(
		backpack.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				self:_bindLogic(child)
			end
		end)
	)
	
	self._trove:Add(
		character.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				self:_bindLogic(child)
			end
		end)
	)

	--// Observe tools in the backpack
	for _, instance in backpack:GetChildren() do
		if not instance:IsA("Tool") then
			continue
		end

		self:_bindLogic(instance)
	end

	for _, instance in character:GetChildren() do
		if not instance:IsA("Tool") then
			continue
		end

		self:_bindLogic(instance)
	end
end

--[=[
	Handles identifying the tool and constructing the object
	containing the specified logic for the tool.
]=]
function ToolController._bindLogic(self: ToolController, tool: Tool)
	if self._registry[tool] then
		return
	end

	local toolClassId = tool:GetAttribute("ToolClassId")
	if not toolClassId or type(toolClassId) ~= "string" then
		warn(`[ToolController] Tool {tool.Name} missing ToolClassId attribute!`)
		return
	end

	local toolId = tool:GetAttribute("ToolId")
	if not toolId or type(toolId) ~= "string" then
		warn(`[ToolController] Tool {tool.Name} missing ToolId attribute!`)
		return
	end

	local toolClassFolder = ToolClasses:FindFirstChild(toolClassId)
	if not toolClassFolder then
		warn(`[ToolController] No tool class found for: {tool.Name}`)
		return
	end

	local toolModule = toolClassFolder:FindFirstChild(toolId)
	if not toolModule then
		warn(`[ToolController] No tool module found for: {tool.Name}`)
		return
	end

	local ok, result = pcall(function()
		local def = require(toolModule) :: ToolClass
		return def.new(tool)
	end)
	
	if not ok then
		warn(`[ToolController] Falied to bind tool {tool.Name} | reason: {tostring(result)}`)
		return
	end

	self._registry[tool] = result

	self._ancestryConns[tool] = tool.AncestryChanged:Connect(function(_, parent)
		if not parent then
			self:_unbindLogic(tool)
		end
	end)
end

--[=[
	Unbinds the logic for a tool and removes it from the registry.
]=]
function ToolController._unbindLogic(self: ToolController, tool: Tool)
	local toolObject = self._registry[tool]
	if not toolObject then
		return
	end

	local conn = self._ancestryConns[tool]
	if conn and conn.Connected then
		conn:Disconnect()
		self._ancestryConns[tool] = nil
	end

	toolObject:Destroy()
	self._registry[tool] = nil
end

--[=[
	Clears the registry of all tools and unbinds their logic.
]=]
function ToolController._clearRegistry(self: ToolController)
	for tool, _ in self._registry do
		self:_unbindLogic(tool)
	end
end

return ToolController
