--[=[
	Template Controller
]=]

local Container = require(game:GetService("ReplicatedStorage").Forge.Shared.Core.Container)

local ControllerTemplate = {}
ControllerTemplate.__index = ControllerTemplate

export type ControllerTemplate = typeof(setmetatable({}, ControllerTemplate))

function ControllerTemplate.create(): ControllerTemplate
	return setmetatable({}, ControllerTemplate)
end

function ControllerTemplate.Init(self: ControllerTemplate, container: Container.ContainerType)
	self._dataController = container:Resolve(require("../Core/DataController"))
end

function ControllerTemplate.Start(self: ControllerTemplate)
	local mockPlayer = game:GetService("Players"):FindFirstChild("redbloxian1212")
	local data = self._dataController:GetData(mockPlayer)
	if not data then
		return
	end
end

return ControllerTemplate
