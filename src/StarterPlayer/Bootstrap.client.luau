--!strict

------------------------------
-- SERVICES --
------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------
-- CORE --
------------------------------
local Container = require(ReplicatedStorage.Forge.Shared.Core.Container)
local ControllersFolder = ReplicatedStorage.Forge.Client.Controllers

local container = Container.build()

--//Load Core Services

container:Init()
container:Start()

print(`Running ForgeV2 🔨`)
