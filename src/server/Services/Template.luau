local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Container = require(ReplicatedStorage.Forge.Shared.Core.Container)
--[=[
    Template for a service module.
]=]

local Template = {}
Template.__index = Template

--[=[
    Define internal fields: methods, properties and dependencies.
]=]
type Fields = {}

export type Template = typeof(setmetatable({} :: Fields, Template))

--[=[
    Very important! This is how the container creates an instance of the service.
]=]
function Template.create(): Template
	local self = setmetatable({} :: Fields, Template)
	return self
end

--[=[
    This is where you resolve your dependencies
]=]
function Template.Init(self: Template, container: Container.ContainerType) end

--[=[
    This is where the logic of your service goes, by this time, all services have been initialized
    and your services should be ready to use.
]=]
function Template.Start(self: Template) end

return Template
