--[[
    Author: src | redbloxian1212
    Created: 08/29/2026 (MM/DD/YYYY)
    Discord: src.dev
]]

------------------------------
-- SERVICES --
------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------
-- DEPENDENCIES --
------------------------------
local Observers = require(ReplicatedStorage.Packages.Observers)

------------------------------
-- TYPES --
------------------------------
type TagName = string
type ModuleName = string
type Object = {
	new: (instance: Instance) -> Object,
	Destroy: (self: Object) -> (),
}
type ObjectData = {
	[TagName]: {
		[Instance]: Object,
	},
}

local function assertFunctionInTable(tbl, funcName)
	if type(tbl[funcName]) ~= "function" then
		error(`Expected function '{funcName}' in component module, but it was not found.`, 2)
	end
end

--[=[
    @class Component

    Description:
    A simple component loader for Forge.

    ### Component Shape
    Every module in the loaded directory must implement the following functions and data:

```luau
    local MyComponent = {
        Tag = "MyTag", -- Tag to listen for in collection service
    }

    function MyComponent.new()
        -- Create a new instance of the component
    end

    function MyComponent:Destroy()
        -- Clean up the component instance
    end

    return MyComponent
```
]=]
local Component = {}
Component._seenTags = {} :: { [string]: string } -- [TagName] = ModuleName
Component._observerCleanupFunctions = {} :: { [string]: () -> () } -- [TagName] = ObserverCleanupFn
Component._objects = {} :: { [string]: { [Instance]: any } }

--[=[
    @within Component
    @param module ModuleScript -- The module to load

    Loads a component
    Does not yield
]=]
function Component.LoadComponent(module: ModuleScript)
	local ok, moduleDef = pcall(require, module)
	if not ok then
		warn(`Failed to require {module:GetFullName()}\nError: {moduleDef}`)
		return
	end

	local success, err = pcall(function()
		if type(moduleDef.Tag) ~= "string" then
			error(`{module.Name} has no tag defined. Please define a string Tag in the module.`, 2)
		end

		if Component._seenTags[moduleDef.Tag] then
			error(`Tag collision between {module.Name} and {Component._seenTags[moduleDef.Tag]}!`, 2)
		end

		assertFunctionInTable(moduleDef, "new")
		assertFunctionInTable(moduleDef, "Destroy")
	end)

	if not success then
		warn(`[Component] Failed to load component: {module:GetFullName()} \n Error: {err}`)
		return
	end

	local tag = moduleDef.Tag
	Component._seenTags[tag] = module.Name
	Component._objects[tag] = {}

	local cleanupObserver = Observers.observeTag(tag, function(instance: Instance)
		local object = moduleDef.new(instance)
		Component._objects[tag][instance] = object

		return function()
			local obj = Component._objects[tag][instance]
			if obj then
				obj:Destroy()
				Component._objects[tag][instance] = nil
			end
		end
	end)

	Component._observerCleanupFunctions[tag] = cleanupObserver
end

--[=[
    @within Component
    @param directory Folder -- The folder containing component modules to load

    Loads all children modules in the given directory that conform to the Component Contract (`.new`, `:Destroy`, and a `Tag` field).
]=]
function Component.LoadDirectory(directory: Folder)
	for _, child in directory:GetChildren() do
		if child:IsA("ModuleScript") then
			Component.LoadComponent(child)
		end
	end
end

--[=[
    @within Component
    @param tag TagName -- The tag whose stored object to fetch
    @param instance Instance -- The instance to look up

    Returns the object stored for that instance under that tag, if any.
]=]
function Component.GetObject(tag: TagName, instance: Instance)
	local bucket = Component._objects[tag]
	return bucket and bucket[instance]
end

--[=[
    @within Component
    @param tag TagName -- The tag to unload

    Unhooks the tag's Observer and destroys every live object under it.
]=]
function Component.UnloadComponent(tag: TagName)
	local cleanup = Component._observerCleanupFunctions[tag]
	if cleanup then
		cleanup()
		Component._observerCleanupFunctions[tag] = nil
	end

	local bucket = Component._objects[tag]
	if bucket then
		for instance, object in bucket do
			object:Destroy()
		end
		Component._objects[tag] = nil
	end

	Component._seenTags[tag] = nil
end

return Component
