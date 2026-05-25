--!strict

local Container = {}
Container.__index = Container

export type ServiceDef<T> = {
	create: (container: any) -> T,
}

export type ContainerType = {
	Resolve: <T>(self: ContainerType, def: ServiceDef<T>) -> T,
	Init: (self: ContainerType) -> (),
	Start: (self: ContainerType) -> (),
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

--[=[
    Resolves a service, obviously.

    Pass the value returned from requiring the module

    Usage:
        local instance = container:Resolve(require(SomeModule))

    Lifecycle:
    - If called before Init, the service is queued and Init will be called on it later.
    - If called during Init (from within another service's Init), the service is
      immediately initialized so the caller gets a ready instance.
    - Cannot be called after Start.
]=]
function Container.Resolve<T>(self: ContainerType, def: ServiceDef<T>): T
	assert(not self._destroyed, `Cannot resolve "{tostring(def)}" after Destroy!`)
	assert(not self._started, `Cannot resolve "{tostring(def)}" after Start!`)
	assert(not self._resolving[def], `Circular dependency detected on "{tostring(def)}"`)

	if self._registry[def] then
		return self._registry[def]
	end

	self._resolving[def] = true
	local instance = def.create(self)
	self._resolving[def] = nil

	self._registry[def] = instance
	table.insert(self._queue, def)

	if self._initing then
		Container._initService(self, def)
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

--[=[
    Runs a lifecycle method on a resolved service.

    Init:
    - Synchronous
    - Resolve your dependencies here
    - Do NOT run logic or yield here, that belongs in Start

    Start:
    - Asynchronous (spawned via task.spawn)
    - All services are guaranteed to be resolved before this runs
    - Safe for logic, event connections, firing events, yielding etc.

    Destroy:
    - Synchronous
    - Called in reverse resolution order
]=]
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
		end
	end
end

--[=[
    Calls :Init() on all queued services in resolution order.

    - Synchronous
    - New services resolved during Init are immediately initialized
      (handled via the _initing flag + dynamic queue walk)
    - Must be called before Start
]=]
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

--[=[
    Calls :Start() on all queued services in resolution order.

    - Each Start runs in its own task.spawn (non-blocking)
    - All Init calls are guaranteed complete before any Start runs
    - No new services may be resolved after this point
]=]
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
    Destroys all services in reverse resolution order (LIFO).

    - Synchronous
    - Safe to call multiple times
    - Clears registry and queue after teardown
]=]
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
