--!strict

------------------------------
-- SERVICES --
------------------------------
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------
-- CORE --
------------------------------
local Container = require(ReplicatedStorage.Forge.Shared.Core.Container)
local ServicesFolder = ServerScriptService.Forge.Services

local core = Container.build()

core:Resolve(require(ServicesFolder.ShopService))

core:Init()
core:Start()
