export type IMonetizationService = {
	Init: (self: IMonetizationService, services: { [string]: any }) -> (),
	Start: (self: IMonetizationService) -> (),
}

return {}
