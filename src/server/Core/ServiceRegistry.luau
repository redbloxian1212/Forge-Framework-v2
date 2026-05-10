--!strict

local isLoaded = false
local toCall: { (any) -> () } = {}
local LoadedServices: any = nil

local ServiceRegistry = {}

function ServiceRegistry.Load(services: any)
	LoadedServices = services

	-- Init (Synchronous)
	for name, service in services :: { [string]: any } do
		if type(service) == "table" and service.Init then
			local ok, err = pcall(service.Init, service, services)
			if not ok then
				warn(`[ServiceRegistry] Init failed for '{name}': {err}`)
			end
		end
	end

	-- Start (Asynchronous)
	for name, service in services :: { [string]: any } do
		if type(service) == "table" and service.Start then
			task.spawn(function()
				local ok, err = pcall(service.Start, service)
				if not ok then
					warn(`[ServiceRegistry] Start error in '{name}': {err}`)
				end
			end)
		end
	end

	isLoaded = true

	for _, callback in toCall do
		task.defer(function()
			local ok, err = pcall(function()
				callback(LoadedServices)
			end)
			if not ok then
				warn(`[ServiceRegistry] Callback error: {err}`)
			end
		end)
	end

	table.clear(toCall)
end

--[[
	Use this if you have external scripts that need to access the framework.
	DO NOT access services directly to avoid race conditions.
	External scripts will have least priority.
]]
function ServiceRegistry.OnServicesLoaded(callback: (services: any) -> ())
	if isLoaded then
		task.defer(function()
			local ok, err = pcall(function()
				callback(LoadedServices)
			end)
			if not ok then
				warn(`[ServiceRegistry] OnServicesLoaded callback error: {err}`)
			end
		end)
	else
		table.insert(toCall, callback)
	end
end

return ServiceRegistry
