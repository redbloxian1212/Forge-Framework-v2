--!strict

------------------------------
-- TYPES --
------------------------------
type Subscribers = { [string]: { (any) -> () } }

local EventBus = {}
local subscribers: Subscribers = {}

--[=[
    @param eventName string: The name of the event to subscribe to.
    @param callback (any) -> (): The function to call when the event is published.
    @return () -> (): A function that can be called to unsubscribe from the event.
]=]
function EventBus.Subscribe(eventName: string, callback: (any) -> ()): () -> ()
	if not subscribers[eventName] then
		subscribers[eventName] = {}
	end

	table.insert(subscribers[eventName], callback)

	return function()
		local targets = subscribers[eventName]
		if not targets then
			return
		end

		local index = table.find(targets, callback)
		if index then
			table.remove(targets, index)
		end

		if #targets == 0 then
			subscribers[eventName] = nil
		end
	end
end

--[=[
    @param eventName string: The name of the event to publish.
    @param data any: The data to pass to the subscribers of the event.
]=]
function EventBus.Publish(eventName: string, data: any)
	local targets = subscribers[eventName]
	if not targets then
		return
	end

	for _, callback in targets do
		task.spawn(callback, data)
	end
end

--[=[
    @param eventPath string: The explicit event path to completely clear.
]=]
function EventBus.ClearEvent(eventPath: string)
	if not subscribers[eventPath] then
		error(`[EventBus] Attempt to clear non-existing event path: {eventPath}`)
	end

	subscribers[eventPath] = nil
end

return EventBus
