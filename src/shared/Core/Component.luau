------------------------------
-- SERVICES --
------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------
-- DEPENDENCIES --
------------------------------
local Observers = require(ReplicatedStorage.Packages.Observers)

local function assertFunctionInTable(tbl, funcName)
    if type(tbl[funcName]) ~= "function" then
        error(`[Component] Expected function '{funcName}' in component module, but it was not found.`, 2)
    end
end

--[=[
    @class Component

    Author: src | redbloxian1212
    Created: 08/29/2026 (MM/DD/YYYY)
    Discord: src.dev

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

    function MyComponent:GetObject()
        -- Return the object indexed by the instance
    end

    function MyComponent:DestroyObject()
        -- Clean up the object indexed by the instance
    end

    function MyComponent:Destroy()
        -- Clean up the component instance
    end

    return MyComponent
```
]=]
local Component = {}
Component._seenTags = {} :: { [string]: string } -- [TagName] = ModuleName

--[=[
    @within Component
    @param module ModuleScript -- The module to load

    Loads a component
    Does not yield
]=]
function Component.LoadComponent(module: ModuleScript)
    -- TODO: Make sure to handle Tag collisions

    task.spawn(function()
        local moduleDef

        local ok, err = pcall(function()
            moduleDef = require(module)

            if type(moduleDef.Tag) ~= "string" then
                error(`[Component] {module.Name} has no tag defined. Please define a string Tag in the module.`, 2)
            end

            if Component._seenTags[moduleDef.Tag] then
                error(`[Component] Tag collision between {module.Name} and {Component._seenTags[moduleDef.Tag]}!`, 2)
            end

            assertFunctionInTable(moduleDef, "new")
            assertFunctionInTable(moduleDef, "GetObject")
            assertFunctionInTable(moduleDef, "DestroyObject")
            assertFunctionInTable(moduleDef, "Destroy")
        end)
        if not ok then
            warn(`[Component] Failed to load component: {module:GetFullName()} \n Error: {err}`)
        end

        Component._seenTags[moduleDef.Tag] = module.Name
    end)
end

--[=[
    @within Component
    @param directory Folder -- The folder containing component modules to load

    Loads all children modules in the given directory that conform to the Component Contract (`.new`, `:GetObject`, `:Destroy`, and a `Tag` field).
]=]
function Component.LoadDirectory(directory: Folder)
    
end

return Component