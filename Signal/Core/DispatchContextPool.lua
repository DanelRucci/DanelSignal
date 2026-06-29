--!strict
--!native
--!optimize 2
--@danel_rucci

local DispatchContext = require(script.Parent.DispatchContext)
type DispatchContext = DispatchContext.DispatchContext

export type DispatchContextPool = typeof(setmetatable({} :: {
    __pool: {DispatchContext},
    __count: number,
}, {} :: any))

--[=[
    @class DispatchContextPool

    Maintains a pool of reusable DispatchContext objects.

    The pool uses a LIFO strategy to maximize cache locality and reduce
    allocations during frequent signal dispatches.
]=]
local DispatchContextPool = {}
DispatchContextPool.__index = DispatchContextPool

--[=[
    @function new
    @within DispatchContextPool

    Creates a new DispatchContextPool.

    @return DispatchContextPool -- The newly created pool.
]=]
function DispatchContextPool.new() : DispatchContextPool
    return setmetatable({
        __pool = {},
        __count = 0,
    }, DispatchContextPool)
end

--[=[
    @function Acquire
    @within DispatchContextPool
    @return DispatchContext

    Acquires a DispatchContext from the pool.

    If no reusable context is available, a new one is allocated.
]=]
function DispatchContextPool:Acquire() : DispatchContext
    local count : number = self.__count

    if count == 0 then
        return DispatchContext.new()
    end

    local pool : {DispatchContext} = self.__pool
    local context : DispatchContext = pool[count]

    pool[count] = nil
    self.__count = count - 1

    return context
end

--[=[
    @function Release
    @within DispatchContextPool

    Returns a DispatchContext to the pool.
    The context is reset before becoming available for reuse.

    @param context DispatchContext
]=]
function DispatchContextPool:Release(context : DispatchContext) : ()
    context:Reset()
    local count : number = self.__count + 1
    self.__count = count
    self.__pool[count] = context
end

--[=[
    @function GetCount
    @within DispatchContextPool

    Returns the number of currently pooled contexts.

    @return number
]=]
function DispatchContextPool:GetCount() : number
    return self.__count
end

--[=[
    @function Clear
    @within DispatchContextPool

    Removes every pooled DispatchContext.
]=]
function DispatchContextPool:Clear() : ()
    table.clear(self.__pool)
    self.__count = 0
end

return table.freeze(DispatchContextPool)