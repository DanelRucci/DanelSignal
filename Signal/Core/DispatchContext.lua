--!strict
--!native
--!optimize 2
--@danel_rucci

--[=[
    @class DispatchContext

    Represents a single event dispatch.

    Every call to DanelSignal:Fire() creates (or acquires from a pool) a
    DispatchContext instance that flows through the entire event pipeline.

    The context is mutable by design and allows operators, middleware and
    dispatchers to exchange state without additional allocations.
]=]
local DispatchContext = {}
DispatchContext.__index = DispatchContext

--[=[
    @type DispatchContext

    A dispatch context is a mutable object that represents a single event dispatch.
    It contains information about the dispatch, such as the signal being dispatched, the connection
    that triggered the dispatch, and any arguments passed to the dispatch.
]=]
export type DispatchContext = typeof(setmetatable({} :: {
    Id : number,
    Timestamp : number,
    Signal : any,
    Connection : any?,
    Arguments : {any},
    Items : {[string] : any},
    Cancelled : boolean,
    PropagationStopped : boolean,
    ArgumentCount : number,
}, DispatchContext))

--[=[
    @function DispatchContext.new
    @within DispatchContext
    @return DispatchContext -- A new dispatch context instance.

    Creates a new dispatch context instance.
]=]
function DispatchContext.new() : DispatchContext
    return setmetatable({
        Id = 0,
        Timestamp = 0,
        Signal = nil,
        Connection = nil,
        Arguments = {},
        Items = {},
        Cancelled = false,
        PropagationStopped = false,
        ArgumentCount = 0,
    }, DispatchContext)
end

--[=[
    @function GetArguments
    @within DispatchContext
    @return {any} -- The current dispatch arguments.

    Returns the current dispatch arguments.
]=]
function DispatchContext:GetArguments() : {any}
    return self.Arguments
end

--[=[
    @function SetArguments
    @within DispatchContext
    @param ... any -- The new dispatch arguments.

    Replaces the dispatch arguments.
    This method reuses the existing table to minimize allocations.
]=]
function DispatchContext:SetArguments(...)
    table.clear(self.Arguments)

    local count : number = select("#", ...)
    self.ArgumentCount = count
    
    for index : number = 1, count do
        self.Arguments[index] = select(index, ...)
    end
end

--[=[
    @function Cancel
    @within DispatchContext

    Prevents any remaining listeners from executing.
]=]
function DispatchContext:Cancel() : ()
    self.Cancelled = true
end

--[=[
    @function IsCancelled
    @within DispatchContext
    @return boolean -- Whether the dispatch has been cancelled.
    
    Returns whether the dispatch has been cancelled.
]=]
function DispatchContext:IsCancelled() : boolean
    return self.Cancelled
end

--[=[
    @function StopPropagation
    @within DispatchContext

    Stops propagation to remaining listeners.

    Unlike cancellation, propagation stop is intended for middleware and
    pipeline control.
]=]
function DispatchContext:StopPropagation() : ()
    self.PropagationStopped = true
end

--[=[
    @function IsPropagationStopped
    @within DispatchContext
    @return boolean -- Whether propagation has been stopped.

    Returns whether propagation has been stopped.
]=]
function DispatchContext:IsPropagationStopped() : boolean
    return self.PropagationStopped
end

--[=[
    @function Reset
    @within DispatchContext

    Resets the context to its default state.

    This method exists to support future object pooling.
]=]
function DispatchContext:Reset() : ()
    self.Id = 0
    self.Timestamp = 0
    self.ArgumentCount = 0

    self.Signal = nil
    self.Connection = nil

    self.Cancelled = false
    self.PropagationStopped = false

    table.clear(self.Arguments)
    table.clear(self.Items)
end

return table.freeze(DispatchContext)