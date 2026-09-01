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
	services being started yet. Setup here, no logic

	@param container ContainerType -- The DI container used to resolve dependencies
]=]
function ServiceTemplate.Init(self: ServiceTemplate, container: Container.ContainerType)
	self._dataService = container:Resolve(require("../Core/DataService"))
	self._latestPlayer = nil :: Player?
end

--[=[
	Called by the container during the Start lifecycle stage, after all
	services have been initialized. Put logic here
]=]
function ServiceTemplate.Start(self: ServiceTemplate)
	--// Example of using the DataService to observe player data changes
	--// In production I usually put observers under "DEPENDENCIES" section, I just did this here for demonstration purposes
	local Observers = require(game:GetService("ReplicatedStorage").Packages.Observers)
	Observers.observePlayer(function(player: Player)
		self._dataService
			:GetDataAsync(player)
			:andThen(function(data: PlayerData)
				print(`{player.Name} joined with data: `, { data })
			end)
			:catch(function(err)
				warn(`Failed to get data for {player.Name}: {err}`)
			end)

		self._latestPlayer = player
	end)
end

return ServiceTemplate
