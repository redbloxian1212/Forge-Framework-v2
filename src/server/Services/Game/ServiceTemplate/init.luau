--[=[
	Template for Services.

	@class ServiceTemplate
]=]

local Container = require(game:GetService("ReplicatedStorage").Forge.Shared.Core.Container)

local ServiceTemplate = {}
ServiceTemplate.__index = ServiceTemplate

export type ServiceTemplate = typeof(setmetatable({}, ServiceTemplate))

--[=[
	Constructs a new ServiceTemplate.

	@return ServiceTemplate
]=]
function ServiceTemplate.create(): ServiceTemplate
	return setmetatable({}, ServiceTemplate)
end

--[=[
	Called by the container during the Init lifecycle stage. Resolves
	dependencies and sets up initial state. Should not rely on other
	services being started yet.

	@param container ContainerType -- The DI container used to resolve dependencies
]=]
function ServiceTemplate.Init(self: ServiceTemplate, container: Container.ContainerType)
	self._dataService = container:Resolve(require("../Core/DataService"))
	self._latestPlayer = nil :: Player?
end

--[=[
	Called by the container during the Start lifecycle stage, after all
	services have been initialized. Hooks into PlayerAdded to load data
	for joining players.
]=]
function ServiceTemplate.Start(self: ServiceTemplate)
	--// Demo purposes only, use observers for such cases in production.
	game.Players.PlayerAdded:Connect(function(player: Player)
		local data = self._dataService:GetData(player)
		if not data then
			player:Kick(`Failed to load your data!`)
			return
		end

		print(`{player.Name} joined with data: {player.Name}: {data}`)
		self._latestPlayer = player
	end)
end

return ServiceTemplate
