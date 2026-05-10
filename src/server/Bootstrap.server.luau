--!strict

------------------------------
-- SERVICES --
------------------------------
local ServerScriptService = game:GetService("ServerScriptService")

------------------------------
-- TYPES --
------------------------------
local ServiceTypes = require(ServerScriptService.Forge.Types.ServiceTypes)

------------------------------
-- SERVICE LIFECYCLE --
------------------------------
local ServicesFolder = ServerScriptService.Forge.Services
local ServiceRegistry = require(ServerScriptService.Forge.Core.ServiceRegistry)

local Services: ServiceTypes.ServiceTypes = {
	DataService = require(ServicesFolder.Data.DataService),
	MonetizationService = require(ServicesFolder.Monetization.MonetizationService),
}

ServiceRegistry.Load(Services)
