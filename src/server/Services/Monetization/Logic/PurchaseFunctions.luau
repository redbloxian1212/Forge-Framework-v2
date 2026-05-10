--!strict

------------------------------
-- SERVICES --
------------------------------
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------
-- CONFIG --
------------------------------
local MonetizationConfig = require(ReplicatedStorage.Forge.Shared.Config.MonetizationConfig)

------------------------------
-- TYPES --
------------------------------
local Types = require(ServerScriptService.Forge.Types.ServiceTypes)
type ServiceTypes = Types.ServiceTypes
type PurchaseInfo = { player: Player }
type PurchaseFunctions = { [number]: (PurchaseInfo, ServiceTypes) -> () }

--[[local function factory(foo: any): (PurchaseInfo, ServiceTypes) -> ()
	return function(purchaseInfo, services)
		print("Yooo")
	end
end]]

local PurchaseLogic: PurchaseFunctions = {}

return PurchaseLogic
