local Container = require(game:GetService("ReplicatedStorage").Forge.Shared.Core.Container)

local MockService = {}
MockService.__index = MockService

export type MockService = typeof(setmetatable({}, MockService))

function MockService.create()
	return setmetatable({}, MockService)
end

function MockService.Init(self: MockService, container: Container.ContainerType)
	self._dataService = container:Resolve(require("./DataService"))
end

function MockService.Start(self: MockService)
	local mockPlayer = game:GetService("Players"):FindFirstChild("redbloxian1212")
	local data = self._dataService:GetData(mockPlayer)
	if not data then
		return
	end
end

return MockService
