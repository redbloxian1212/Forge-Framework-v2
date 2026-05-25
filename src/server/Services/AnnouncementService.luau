--!strict
local AnnouncementService = {}
AnnouncementService.__index = AnnouncementService

type Fields = {}

-- Fixed: Uses the same robust metatable type derivation as ShopService
export type AnnouncementService = typeof(setmetatable({} :: Fields, AnnouncementService))

function AnnouncementService.create(_container: any): AnnouncementService
	return setmetatable({} :: Fields, AnnouncementService)
end

function AnnouncementService.Init(self: AnnouncementService, container: any)
	-- Left blank intentionally for container lifecycle consistency
end

-- Converted to dot notation with explicit self injection
function AnnouncementService.Announce(self: AnnouncementService, player: Player, itemName: string)
	warn(`{player.Name} just bought: {itemName}!`)
end

return AnnouncementService
