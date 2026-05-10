--!strict

local isLoaded = false
local toCall: { (any) -> () } = {}
local LoadedControllers: any = nil

local ControllerRegistry = {}

function ControllerRegistry.Load(controllers: any)
	LoadedControllers = controllers

	-- Init (Synchronous)
	for name, controller in controllers :: { [string]: any } do
		if type(controller) == "table" and controller.Init then
			local ok, err = pcall(controller.Init, controller, controllers)
			if not ok then
				warn(`[ControllerRegistry] Init failed for '{name}': {err}`)
			end
		end
	end

	-- Start (Asynchronous)
	for name, controller in controllers :: { [string]: any } do
		if type(controller) == "table" and controller.Start then
			task.spawn(function()
				local ok, err = pcall(controller.Start, controller)
				if not ok then
					warn(`[ControllerRegistry] Start error in '{name}': {err}`)
				end
			end)
		end
	end

	isLoaded = true

	for _, callback in toCall do
		task.defer(function()
			local ok, err = pcall(function()
				callback(LoadedControllers)
			end)
			if not ok then
				warn(`[ControllerRegistry] Callback error: {err}`)
			end
		end)
	end

	table.clear(toCall)
end

--[[
	Use this if you have external scripts that need to access the framework.
	DO NOT access controllers directly to avoid race conditions.
	External scripts will have least priority.
]]
function ControllerRegistry.OnControllersLoaded(callback: (controllers: any) -> ())
	if isLoaded then
		task.defer(function()
			local ok, err = pcall(function()
				callback(LoadedControllers)
			end)
			if not ok then
				warn(`[ControllerRegistry] OnControllersLoaded callback error: {err}`)
			end
		end)
	else
		table.insert(toCall, callback)
	end
end

return ControllerRegistry
