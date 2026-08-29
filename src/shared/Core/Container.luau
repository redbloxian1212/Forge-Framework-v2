--!strict

--[=[
	@class Container

	Author: src | redbloxian1212
    Created: 05/26/2026 (MM/DD/YYYY)
    Discord: src.dev

	Description: Skibidi dop dop dop yes yes
]=]

local Container = {}
Container.__index = Container

export type ServiceDef<T> = {
	create: () -> T,
}

export type LifeCylceDef = {
	create: () -> any, --// I just wanted to silence the type checker lol
	Init: (self: any, container: ContainerType) -> (),
	Start: (self: any) -> (),
	Destroy: ((self: any) -> ())?,
}

export type ResolveDirOptions = {
	allowMissingDestroyFunction: boolean? --// a bit awkward but its the best name I could think of
}

export type ContainerType = {
	Resolve: <T>(self: ContainerType, def: ServiceDef<T>) -> T,
	Init: (self: ContainerType) -> (),
	Start: (self: ContainerType) -> (),
	ResolveDirectory: (self: ContainerType, directory: Folder, options: ResolveDirOptions) -> (),
	Destroy: (self: ContainerType) -> (),
	_initService: (self: ContainerType, def: any) -> (),
	_run: (self: ContainerType, def: any, method: "Init" | "Start" | "Destroy") -> (),

	_registry: { [any]: any },
	_states: { [any]: "Initializing" | "Initialized" },
	_resolving: { [any]: boolean },
	_queue: { any },
	_initing: boolean,
	_started: boolean,
	_destroyed: boolean,
}

--[=[
    Build the almighty container!
]=]
function Container.build(): ContainerType
	return setmetatable({
		_registry = {},
		_states = {},
		_resolving = {},
		_queue = {},
		_initing = false,
		_started = false,
		_destroyed = false,
	}, Container) :: any
end

function Container.Resolve<T>(self: ContainerType, def: ServiceDef<T>): T
	assert(not self._destroyed, `Cannot resolve "{tostring(def)}" after Destroy!`)
	assert(not self._started, `Cannot resolve "{tostring(def)}" after Start!`)
	assert(not self._resolving[def], `Circular dependency detected on "{tostring(def)}"`)

	if self._registry[def] then
		return self._registry[def]
	end

	self._resolving[def] = true
	local instance = def.create()
	self._resolving[def] = nil

	self._registry[def] = instance

	table.insert(self._queue, def)

	if self._initing then
		Container._initService(self, def)
		Container._run(self, def, "Start")
	end

	return instance
end

function Container._initService(self: ContainerType, def: any)
	local state = self._states[def]
	if state == "Initialized" then
		return
	end

	assert(state ~= "Initializing", `Circular dependency chain detected during Init phase on: "{tostring(def)}"`)

	self._states[def] = "Initializing"
	Container._run(self, def, "Init")
	self._states[def] = "Initialized"
end

function Container:_run(def: any, method: "Init" | "Start" | "Destroy")
	local service = self._registry[def]
	if not service then
		return
	end

	if method == "Init" then
		if type(service.Init) == "function" then
			service.Init(service, self)
		end
	elseif method == "Start" then
		if type(service.Start) == "function" then
			task.spawn(function()
				service.Start(service)
			end)
		end
	elseif method == "Destroy" then
		if type(service.Destroy) == "function" then
			service.Destroy(service)
		else
			warn("No Destroy method found!") --// this sucks.
		end
	end
end

function Container.Init(self: ContainerType)
	assert(not self._destroyed, "Already destroyed!")
	assert(not self._initing, "Already initializing!")
	assert(not self._started, "Already started!")

	self._initing = true

	for _, def in self._queue do
		Container._initService(self, def)
	end

	self._initing = false
end

function Container.Start(self: ContainerType)
	assert(not self._destroyed, "Already destroyed!")
	assert(not self._initing, "Still initializing!")
	assert(not self._started, "Already started!")

	self._started = true

	for _, def in self._queue do
		Container._run(self, def, "Start")
	end
end

--[=[
	Resolves every controller/service directly inside target directory.
]=]
function Container.ResolveDirectory(self: ContainerType, directory: Folder, options: ResolveDirOptions)
	if typeof(directory) ~= "Instance" or not directory:IsA("Folder") then
		return
	end

	if type(options) ~= "table" then
		options = {}
	end

	for _, module in directory:GetChildren() do
		if not module:IsA("ModuleScript") then
			warn(`[Container] Encountered a Non-ModuleScript in a directory! \n Path: {module:GetFullName()}`)
			continue
		end

		local moduleDef = require(module) :: LifeCylceDef
		if type(moduleDef) ~= "table" then
			warn(`[Container] A module did not return a table! \n Path: {module:GetFullName()}`)
			continue
		end
		
		assert(type(moduleDef.Init) == "function", `[Container] Missing Init function! \n Path: {module:GetFullName()}`)
		assert(type(moduleDef.Start) == "function", `[Container] Missing Start function! \n Path: {module:GetFullName()}`)
		
		if type(moduleDef.Destroy) ~= "function" and not options.allowMissingDestroyFunction then
			warn(`[Container] Missing Destroy function! \n Path: {module:GetFullName()}`)
		end

		self:Resolve(moduleDef)
	end
end

function Container.Destroy(self: ContainerType)
	if self._destroyed then
		return
	end
	self._destroyed = true

	for i = #self._queue, 1, -1 do
		Container._run(self, self._queue[i], "Destroy")
	end

	table.clear(self._registry)
	table.clear(self._states)
	table.clear(self._queue)
end

return Container
