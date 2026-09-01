--[=[
	Template Controller

	@class ControllerTemplate
]=]

local Container = require(game:GetService("ReplicatedStorage").Forge.Shared.Core.Container)

local ControllerTemplate = {}
ControllerTemplate.__index = ControllerTemplate

export type ControllerTemplate = typeof(setmetatable({}, ControllerTemplate))

--[=[
	Constructs a new ControllerTemplate.

	@return ControllerTemplate
]=]
function ControllerTemplate.create(): ControllerTemplate
	return setmetatable({}, ControllerTemplate)
end

--[=[
	Called by the container during the Init lifecycle stage. Resolves
	dependencies and sets up initial state. Should not rely on other
	controllers being started yet.

	@param container ContainerType -- The DI container used to resolve dependencies
]=]
function ControllerTemplate.Init(self: ControllerTemplate, container: Container.ContainerType)
	self._dataController = container:Resolve(require("../Core/DataController"))
	self._myVariable = "Foo"
end

--[=[
	Called by the container during the Start lifecycle stage, after all
	controllers have been initialized. Safe to assume other controllers
	are ready to use here.
]=]
function ControllerTemplate.Start(self: ControllerTemplate)
	self._dataController.OnDataReady:Wait()
	local data = self._dataController:GetData()
	if not data then
		warn(`Failed to get data!`)
		return
	end

	print(`Received data:`, data)
	print(`My variable: {self._myVariable}`)
end

return ControllerTemplate
