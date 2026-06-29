--!strict
--!native
--!optimize 2
--@danel_rucci

local Types = require(script.Parent.Types)
type Callback = Types.Callback

--[=[
    @type Listener

    A listener is a callback function that is registered to a Signal.
    It has an identity (id, order, callback, priority and tag) and a run state (connected or enabled).
]=]
export type Listener = {
    id : number,
    order : number,
    priority : number,
    tag : string?,
    callback : Callback,
    connected : boolean,
    enabled : boolean,
}

--[=[
    @class Listener

    Represents an internal event listener.

    Listeners are immutable with respect to their identity (id, order,
    callback, priority and tag). Only their run state (connected
    or enabled) is expected to change over their lifetime.

    This class is internal to the Signal runtime.
]=]
local Listener = {}

--[=[
    @function new
    @within Listener

    Creates a new listener.

    @param id number
    @param order number
    @param callback Callback
    @param priority number?
    @param tag string?

    @return Listener
]=]
function Listener.new(id : number, order : number, callback : Callback, priority : number?, tag : string?) : Listener
    return {
        id = id,
        order = order,
        priority = priority or 0,
        tag = tag,
        callback = callback,
        connected = true,
        enabled = true,
    }
end

return table.freeze(Listener)