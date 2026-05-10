-- !strict

------------------------------
-- SERVICES --
------------------------------
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

------------------------------
-- DEPENDENCIES --
------------------------------
local Services

------------------------------
-- MODULES --
------------------------------
local PurchaseLogic = require("./Logic/PurchaseFunctions")

------------------------------
-- TYPES --
------------------------------
local ServerTypes = ServerScriptService.Forge.Types
local ServiceTypes = require(ServerTypes.ServiceTypes)
local IMonetizationService = require(ServerTypes.Interfaces.IMonetizationService)

type ReceiptInfo = {
	PurchaseId: string,
	PlayerId: number,
	ProductId: number,
	CurrencyType: Enum.CurrencyType,
	CurrencySpent: number,
	PlaceIdWherePurchased: number,
}

local MonetizationService = {} :: IMonetizationService.IMonetizationService

function MonetizationService:Init(services: ServiceTypes.ServiceTypes)
	Services = services
end

function MonetizationService:Start()
	MarketplaceService.ProcessReceipt = function(receiptInfo: ReceiptInfo): Enum.ProductPurchaseDecision
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		local profileData = player and Services.DataService:GetData(player)

		if not profileData then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		if profileData.PurchaseHistory[receiptInfo.PurchaseId] then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		local purchaseFn = PurchaseLogic[receiptInfo.ProductId]

		if not purchaseFn then
			warn(`[MONETIZATION] MISSING FUNCTION! ID: {receiptInfo.ProductId}`)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local purchaseInfo = {
			player = player,
		}
		local success, err = pcall(function()
			purchaseFn(purchaseInfo, Services)
		end)

		if not success then
			warn(`[MONETIZATION] Reward Failed for ID: {receiptInfo.ProductId} | Error: `, err)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		profileData.PurchaseHistory[receiptInfo.PurchaseId] = true
		profileData.RobuxSpent = (profileData.RobuxSpent or 0) + receiptInfo.CurrencySpent

		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

return MonetizationService
