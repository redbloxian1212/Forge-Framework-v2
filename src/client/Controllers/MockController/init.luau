local Container = require(game:GetService("ReplicatedStorage").Forge.Shared.Core.Container)

local MockController = {}
MockController.__index = MockController

export type MockController = typeof(setmetatable({}, MockController))

function MockController.create(): MockController
	return setmetatable({}, MockController)
end

function MockController.Init(self: MockController, container: Container.ContainerType)
	self._dataController = container:Resolve(require("./DataController"))
end

function MockController.Start(self: MockController)
	local mockPlayer = game:GetService("Players"):FindFirstChild("redbloxian1212")
	local data = self._dataController:GetData(mockPlayer)
	if not data then
		return
	end
end

return MockController
