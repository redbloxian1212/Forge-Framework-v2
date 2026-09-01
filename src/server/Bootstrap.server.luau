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
local Component = require(ReplicatedStorage.Forge.Shared.Core.Component)
local ForgeServer = ServerScriptService.Forge

local container = Container.build()

--// Resolve Services
container:ResolveDirectory(ForgeServer.Services.Core, { allowMissingDestroyFunction = true })
container:ResolveDirectory(ForgeServer.Services.Game, { allowMissingDestroyFunction = true })

--// Load components
Component.LoadDirectory(ForgeServer.Components)

container:Init()
container:Start()

print(`Running ForgeV2 🔨`)
