--!strict
local ServerScriptService = game:GetService("ServerScriptService")

-- Interface References
local Interfaces = ServerScriptService.Forge.Types.Interfaces
local IMonetizationService = require(Interfaces.IMonetizationService)
local IDataService = require(Interfaces.IDataService)

export type ServiceTypes = {
	DataService: DataService,
	MonetizationService: MonetizationService,
}

export type MonetizationService = IMonetizationService.IMonetizationService
export type DataService = IDataService.IDataService

return {}
