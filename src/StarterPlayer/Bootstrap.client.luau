--!strict

------------------------------
-- SERVICES --
------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------
-- CORE --
------------------------------
local Container = require(ReplicatedStorage.Forge.Shared.Core.Container)
local Core = ReplicatedStorage.Forge.Client.Controllers.Core
local ControllersFolder = ReplicatedStorage.Forge.Client.Controllers

local container = Container.build()

--// Resolve Core Controllers
container:Resolve(require(Core.DataController))
container:Resolve(require(Core.ToolController))
container:Resolve(require(Core.UiController))

container:ResolveDirectory(ControllersFolder, {})

container:Init()
container:Start()

print(`Running ForgeV2 🔨`)
