--!strict
--!native
--!optimize 2
--@danel_rucci

local ListenerList = require(script.Parent.ListenerList)
local DispatchContext = require(script.Parent.DispatchContext)

type Listener = ListenerList.Listener
type DispatchContext = DispatchContext.DispatchContext

export type Dispatcher = typeof(setmetatable({} :: {
	__listener_list : ListenerList.ListenerList,
}, {} :: any))

--[=[
	@class Dispatcher

	Dispatches events to listeners.

	The dispatcher is responsible only for iterating listeners and invoking
	their callbacks. Scheduling, middleware, metrics and error handling are
	intentionally delegated to other runtime components.
]=]
local Dispatcher = {}
Dispatcher.__index = Dispatcher

--[=[
    @function Dispatcher.new
    @within Dispatcher
    @param listener_list ListenerList -- The listener list to dispatch to.
    @return Dispatcher -- A new dispatcher instance.

    Creates a new dispatcher instance.
]=]
function Dispatcher.new(listener_list : ListenerList.ListenerList) : Dispatcher
	return setmetatable({
		__listener_list = listener_list,
	}, Dispatcher)
end

--[=[
    @function Dispatcher:_invoke
    @within Dispatcher
	@private

    Invokes the supplied listener with the supplied dispatch context.

    @param listener Listener -- The listener to invoke.
    @param context DispatchContext -- The dispatch context to invoke with.
]=]
function Dispatcher:_invoke(listener : Listener, context : DispatchContext) : ()
	listener.callback(table.unpack(context.Arguments, 1, context.ArgumentCount))
end

--[=[
	@function Dispatch
	@within Dispatcher

	Dispatches the supplied context to every eligible listener.
]=]
function Dispatcher:Dispatch(context : DispatchContext) : ()
	for listener in self.__listener_list:Iter() do
		if context.Cancelled then
			break
		end

		if listener.connected and listener.enabled then
			self:_invoke(listener, context)
		end
	end
end

return table.freeze(Dispatcher)