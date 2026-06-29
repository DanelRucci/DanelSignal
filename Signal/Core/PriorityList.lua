--!strict
--!native
--!optimize 2
--@danel_rucci

local BinarySearch = require(script.Parent.Parent.Util.BinarySearch)
local Types = require(script.Parent.Types)

--[=[
    @type Listener Types.Listener

    A listener is a table containing metadata and a callback function for a signal connection.
    Listeners look like this:

    ```lua
    {
        id = 1,
        priority = 0,
        enabled = true,
        tag = "example",
        callback = function() end,
    }
    ```
]=]
type Listener = Types.Listener

export type PriorityList = {
    Insert : (self : PriorityList, listener : Listener) -> (),
    Remove : (self : PriorityList, listener : Listener) -> boolean,
    Clear : (self : PriorityList) -> (),
    GetCount : (self : PriorityList) -> number,
    ToArray : (self : PriorityList) -> {Listener},
    Iter : (self : PriorityList) -> (() -> Listener?),

    __listeners : {Listener},
    __count : number,
}

--[=[
    @class PriorityList

    Maintains a stable priority-sorted collection of listeners.

    Listeners are ordered by descending priority while preserving FIFO order
    for listeners sharing the same priority.
]=]
local PriorityList = {}
PriorityList.__index = PriorityList

--[=[
    @function compare
    @within PriorityList
    @param left Listener -- The first listener to compare.
    @param right Listener -- The second listener to compare.
    @return boolean -- Whether <left> should be ordered before <right>.
    @yields
    @private

    Compares two listeners by priority and ID, returning true if <left> should be ordered before <right>.
]=]
local function compare(left : Listener, right : Listener) : boolean
    if left.priority ~= right.priority then
        return left.priority > right.priority
    end
    return left.order < right.order
    --return left.id < right.id
end

--[=[
    @function new
    @within PriorityList
    @return PriorityList -- A new priority list.

    Creates a new priority list.
]=]
function PriorityList.new() : PriorityList
    return setmetatable({
        __listeners = {},
        __count = 0,
    }, PriorityList)
end

--[=[
    @function Insert
    @within PriorityList
    @param listener Listener -- The listener to insert.

    Inserts a listener into the priority list, maintaining order.
]=]
function PriorityList:Insert(listener : Listener) : ()
    local index : number = BinarySearch.LowerBound(self.__listeners, listener, compare)
    table.insert(self.__listeners, index, listener)
    self.__count += 1
end

--[=[
    @function Remove
    @within PriorityList
    @param listener Listener -- The listener to remove.
    @return boolean -- Whether the listener was found and removed.

    Removes a listener from the priority list.
]=]
function PriorityList:Remove(listener : Listener) : boolean
    local listeners : {Listener} = self.__listeners

    for index : number = 1, self.__count do
        if listeners[index] == listener then
            table.remove(listeners, index)
            self.__count -= 1

            return true
        end
    end

    return false
end

--[=[
    @function Clear
    @within PriorityList

    Clears all listeners from the priority list.
]=]
function PriorityList:Clear() : ()
    table.clear(self.__listeners)
    self.__count = 0
end

--[=[
    @function GetCount
    @within PriorityList
    @return number -- The number of listeners in the priority list.

    Returns the number of listeners in the priority list.
]=]
function PriorityList:GetCount() : number
    return self.__count
end

--[=[
    @function ToArray
    @within PriorityList
    @return {Listener} -- An array of listeners in the priority list.

    Returns a shallow copy of the listeners in the priority list.
]=]
function PriorityList:ToArray() : {Listener}
    return table.clone(self.__listeners)
end

--[=[
    @function Iter
    @within PriorityList
    @return (() -> Listener?) -- An iterator function for the listeners in the priority list.

    Returns an iterator function for the listeners in the priority list.
]=]
function PriorityList:Iter()
    local index : number = 0
    local listeners : {Listener} = self.__listeners
    local count : number = self.__count

    return function()
        index += 1

        if index <= count then
            return listeners[index]
        end

        return nil
    end
end

return table.freeze(PriorityList)