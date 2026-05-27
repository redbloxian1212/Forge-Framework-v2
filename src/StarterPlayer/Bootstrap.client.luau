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

local core = Container.build()

core:Init()
core:Start()
