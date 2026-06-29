--!strict
--!native
--!optimize 2
--@danel_rucci

--[=[
    @class Types

    Collection of immutable type definitions shared across the DanelSignal runtime.

    This module intentionally contains no runtime logic and exists solely
    to centralize exported LuaU types, reducing circular dependencies and
    improving maintainability over updates.
]=]

export type Callback = (...any) -> ()

export type Middleware = (context : DispatchContext, next : () -> ()) -> ()

export type Predicate = (... any) -> boolean

export type Mapper = (... any) -> (... any)

export type DispatchPolicy = "Immediate" | "Deferred" | "Spawn" | "Parallel"

export type ConnectionOptions = {
    priority : number?,
    tag : string?,
    enabled : boolean?,
}

export type DispatchContext = {
    id : number,
    signal : any,
    connection : any?,
    timestamp : number,
    arguments : {any},
    metadata : {[string]: any},
    cancelled : boolean,
    propagation_stopped : boolean,
}

export type Connection = {
    Connected : boolean,
    Enabled : boolean,
    Priority : number,
    Tag : string?,
}

export type Metrics = {
    fires : number,
    listeners : number,
    average_dispatch_time : number,
    peak_dispatch_time : number,
    last_dispatch_time : number,
    slowest_callback_time : number,
}

-- TODO: Document all the types.

return nil