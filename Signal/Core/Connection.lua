--!strict
--!native
--!optimize 2
--@danel_rucci

local Types = require(script.Parent.Types)
type Listener = Types.Listener

--[=[
    @type DisconnectCallback

    A callback function that is called when a Connection is disconnected.
]=]
export type DisconnectCallback = (Connection) -> ()

--[=[
    @type Connection

    Represents a connection to a Signal.
    A Connection is a lightweight handle that provides lifecycle
    control over an associated listener.
]=]
export type Connection = typeof(setmetatable({} :: {
    __listener: Listener,
    __disconnect: DisconnectCallback,
}, {} :: any))

--[=[
    @class Connection
    @__index Connection

    Represents a listener attached to a Signal.

    A Connection is a lightweight handle that provides lifecycle control
    over an associated listener.

    Mutable state is stored exclusively within the Listener.
]=]
local Connection = {}
Connection.__index = Connection

--[=[
    @function Connection.new
    @within Connection
    @param listener Listener -- The listener associated with this connection.
    @param disconnect DisconnectCallback -- A callback function that is called when the connection is disconnected.
    @return Connection -- A new connection instance.

    Creates a new connection instance.
]=]
function Connection.new(listener : Listener, disconnect : DisconnectCallback) : Connection
    return setmetatable({
        __listener = listener,
        __disconnect = disconnect,
    }, Connection)
end

--[=[
    @function Disconnect
    @within Connection

    Permanently disconnects this listener.
    Calling Disconnect multiple times is safe.
]=]
function Connection:Disconnect() : ()
    local listener : Listener = self.__listener

    if not listener.connected then
        return
    end

    listener.connected = false
    listener.enabled = false

    self.__disconnect(self)
end

--[=[
    @function Destroy
    @within Connection
    @alias Disconnect

    Alias for Disconnect.
]=]
function Connection:Destroy() : ()
    self:Disconnect()
end

--[=[
    @function Enable
    @within Connection

    Enables this listener.
]=]
function Connection:Enable() : ()
    local listener : Listener = self.__listener

    if listener.connected then
        listener.enabled = true
    end
end

--[=[
    @function Disable
    @within Connection

    Disables this listener without removing it.
]=]
function Connection:Disable() : ()
    local listener : Listener = self.__listener

    if listener.connected then
        listener.enabled = false
    end
end

--[=[
    @function IsConnected
    @within Connection
    @return boolean -- Whether this listener is connected.

    Returns whether this listener is connected.
]=]
function Connection:IsConnected() : boolean
    return self.__listener.connected
end

--[=[
    @function IsEnabled
    @within Connection
    @return boolean -- Whether this listener is enabled.

    Returns whether this listener is enabled.
]=]
function Connection:IsEnabled() : boolean
    return self.__listener.enabled
end

--[=[
    @function GetPriority
    @within Connection
    @return number -- The listener's priority.

    Returns this listener's priority.
]=]
function Connection:GetPriority() : number
    return self.__listener.priority
end

--[=[
    @function GetTag
    @within Connection
    @return string? -- The listener's tag, if one exists.

    Returns this listener's tag, if one exists.
]=]
function Connection:GetTag() : string?
    return self.__listener.tag
end

--[=[
    @function GetContext
    @within Connection
    @return number -- The listener's unique identifier.

    Returns the unique listener identifier.
    Every listener has a unique identifier that is used to identify it within the Signal.
]=]
function Connection:GetId(): number
    return self.__listener.id
end

--[=[
    @function GetListener
    @within Connection
    @return Listener
    @private

    Returns the underlying listener object.
    This is used internally by the DanelSignal class and should not be called directly.
]=]
function Connection:GetListener() : Listener
    return self.__listener
end

return table.freeze(Connection)