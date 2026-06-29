--!strict
--!native
--!optimize 2
--@danel_rucci

local PriorityList = require(script.Parent.PriorityList)
local Listener = require(script.Parent.Listener)

export type Listener = Listener.Listener

--[=[
    @type ListenerList

    List of listeners attached to a Signal.
    Listeners are stored in a priority list, which is sorted by priority and insertion order.
]=]
export type ListenerList = typeof(setmetatable({} :: {
    __priority_list : PriorityList.PriorityList,
}, {} :: any))

--[=[
    @class ListenerList
    @__index ListenerList

    Owns and manages all listeners attached to a Signal.

    ListenerList is responsible only for storage and iteration.
    It does not execute callbacks or create listeners.
]=]
local ListenerList = {}
ListenerList.__index = ListenerList

--[=[
    @function new
    @within ListenerList

    Creates a new ListenerList.
]=]
function ListenerList.new() : ListenerList
    return setmetatable({
        __priority_list = PriorityList.new(),
    }, ListenerList)
end

--[=[
    @function Add
    @within ListenerList

    Inserts a listener into the priority list.
]=]
function ListenerList:Add(listener : Listener) : ()
    self.__priority_list:Insert(listener)
end

--[=[
    @function Remove
    @within ListenerList

    Removes a listener from the list.

    @return boolean
]=]
function ListenerList:Remove(listener : Listener) : boolean
    return self.__priority_list:Remove(listener)
end

--[=[
    @function Clear
    @within ListenerList

    Removes every listener.
]=]
function ListenerList:Clear() : ()
    self.__priority_list:Clear()
end

--[=[
    @function GetCount
    @within ListenerList

    Returns the number of listeners in the list.

    @return number -- The number of listeners in the list.
]=]
function ListenerList:GetCount() : number
    return self.__priority_list:GetCount()
end

--[=[
    @function Iter
    @within ListenerList

    Returns an iterator over every listener.
]=]
function ListenerList:Iter()
    return self.__priority_list:Iter()
end

return table.freeze(ListenerList)