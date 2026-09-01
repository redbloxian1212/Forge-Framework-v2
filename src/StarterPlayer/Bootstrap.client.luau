--!strict

------------------------------
-- SERVICES --
------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------
-- CORE --
------------------------------
local Container = require(ReplicatedStorage.Forge.Shared.Core.Container)
local Component = require(ReplicatedStorage.Forge.Shared.Core.Component)
local ForgeClient = ReplicatedStorage.Forge.Client

local container = Container.build()

--// Resolve Controllers
container:ResolveDirectory(ForgeClient.Controllers.Core, { allowMissingDestroyFunction = true })
container:ResolveDirectory(ForgeClient.Controllers.Game, { allowMissingDestroyFunction = true })

--// Load Components
Component.LoadDirectory(ForgeClient.Components)

container:Init()
container:Start()

print(`Running ForgeV2 🔨`)
