--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnnouncementServiceMod = require(script.Parent.AnnouncementService)

type Item = { name: string, price: number }
local _ITEMS: { Item } = {
	{ name = "Sword", price = 50 },
	{ name = "Shield", price = 30 },
}

local ShopService = {}
ShopService.__index = ShopService

type Fields = {
	_announcement: AnnouncementServiceMod.AnnouncementService,
	_coins: { [Player]: number },
}

export type ShopService = typeof(setmetatable({} :: Fields, ShopService))

function ShopService.create(): ShopService
	local self = setmetatable({} :: Fields, ShopService)

	return self
end

-- 4. Bootstrap Phase (Safe to resolve dependencies here)
function ShopService.Init(self: ShopService, container: any)
	self._coins = {}
	self._announcement = container:Resolve(AnnouncementServiceMod)
end

-- 5. Execution Phase
function ShopService.Start(self: ShopService)
	local remote = ReplicatedStorage:WaitForChild("BuyTest") :: RemoteEvent

	remote.OnServerEvent:Connect(function(player: Player, itemName: unknown)
		if type(itemName) ~= "string" then
			return
		end
		ShopService._handleBuy(self, player, itemName)
	end)
end

function ShopService._handleBuy(self: ShopService, player: Player, itemName: string)
	-- Explicit dot notation and manual passing of self
	self._announcement:Announce(player, itemName)
end

function ShopService.Destroy(self: ShopService)
	table.clear(self._coins)
end

return ShopService
