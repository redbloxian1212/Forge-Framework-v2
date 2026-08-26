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
local Core = ServerScriptService.Forge.Core
local ServicesFolder = ServerScriptService.Forge.Services

local container = Container.build()

--// Resolve Core Services
container:Resolve(require(Core.DataService))

container:Init()
container:Start()

print(`Running ForgeV2 🔨`)
