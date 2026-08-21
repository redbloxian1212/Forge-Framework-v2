--[=[
	Template for Services.
]=]

local Container = require(game:GetService("ReplicatedStorage").Forge.Shared.Core.Container)

local ServiceTemplate = {}
ServiceTemplate.__index = ServiceTemplate

export type ServiceTemplate = typeof(setmetatable({}, ServiceTemplate))

function ServiceTemplate.create(): ServiceTemplate
	return setmetatable({}, ServiceTemplate)
end

function ServiceTemplate.Init(self: ServiceTemplate, container: Container.ContainerType)
	self._dataService = container:Resolve(require("../Core/DataService"))
end

function ServiceTemplate.Start(self: ServiceTemplate)
	local mockPlayer = game:GetService("Players"):FindFirstChild("redbloxian1212")
	local data = self._dataService:GetData(mockPlayer)
	if not data then
		return
	end
end

return ServiceTemplate
