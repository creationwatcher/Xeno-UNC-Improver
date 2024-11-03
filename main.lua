local namecall_method = nil
local readonly_tables = {}
local websocket_connections = {}

function hookfunction(original, hook)
    local original_type = type(original)
    if original_type ~= "function" then
        error("Expected a function to hook")
    end
    return function(...)
        return hook(original(...))
    end
end

function getconstant(func, index)
    if type(func) ~= "function" then
        error("Expected a function as first argument")
    end
    local constants = {}
    local i = 1
    while true do
        local constant = debug.getconstant(func, i)
        if constant == nil then break end
        table.insert(constants, constant)
        i = i + 1
    end
    return constants[index]
end

function getconstants(func)
    if type(func) ~= "function" then
        error("Expected a function as first argument")
    end
    local constants = {}
    local i = 1
    while true do
        local constant = debug.getconstant(func, i)
        if constant == nil then break end
        table.insert(constants, constant)
        i = i + 1
    end
    return constants
end

function getproto(func, index)
    if type(func) ~= "function" then
        error("Expected a function as first argument")
    end
    local protos = {}
    local i = 1
    while true do
        local proto = debug.getproto(func, i)
        if proto == nil then break end
        table.insert(protos, proto)
        i = i + 1
    end
    return protos[index]
end

function getprotos(func)
    if type(func) ~= "function" then
        error("Expected a function as first argument")
    end
    local protos = {}
    local i = 1
    while true do
        local proto = debug.getproto(func, i)
        if proto == nil then break end
        table.insert(protos, proto)
        i = i + 1
    end
    return protos
end

function getstack(level)
    return debug.getstack(level)
end

function getupvalue(func, index)
    if type(func) ~= "function" then
        error("Expected a function as first argument")
    end
    local name, value = debug.getupvalue(func, index)
    return name, value
end

function getupvalues(func)
    if type(func) ~= "function" then
        error("Expected a function as first argument")
    end
    local upvalues = {}
    local i = 1
    while true do
        local name, value = getupvalue(func, i)
        if name == nil then break end
        upvalues[name] = value
        i = i + 1
    end
    return upvalues
end

function setconstant(func, index, value)
    if type(func) ~= "function" then
        error("Expected a function as first argument")
    end
    local constants = {}
    local i = 1
    while true do
        local constant = debug.getconstant(func, i)
        if constant == nil then break end
        table.insert(constants, constant)
        i = i + 1
    end

    if index > 0 and index <= #constants then
        local new_const = constants[index]
        if new_const then
            debug.setupvalue(func, index, value)
        end
    end
end

function setupvalue(func, index, value)
    if type(func) ~= "function" then
        error("Expected a function as first argument")
    end
    local name, oldValue = getupvalue(func, index)
    if name then
        debug.setupvalue(func, index, value)
    end
    return oldValue
end

function getrawmetatable(obj)
    return nil
end

function hookmetamethod(t, methodName, hook)
    local original = t[methodName]
    if original then
        t[methodName] = function(...)
            return hook(original, ...)
        end
    end
end

function getnamecallmethod()
    return namecall_method
end

function setnamecallmethod(method)
    namecall_method = method
end

function setrawmetatable(obj, mt)
    for k, v in pairs(mt) do
        obj[k] = v
    end
end

function setreadonly(t, readonly)
    if readonly then
        readonly_tables[t] = true
    else
        readonly_tables[t] = nil
    end
end

function getrenv(func)
    return _G
end

function websocket_connect(url)
    if not url or type(url) ~= "string" then
        error("Invalid URL")
    end
    
    local connection_id = #websocket_connections + 1
    websocket_connections[connection_id] = { url = url, status = "connected" }
    
    return {
        send = function(message)
            if websocket_connections[connection_id].status == "connected" then
                print("Message sent: " .. message)
            else
                error("WebSocket is not connected")
            end
        end,
        close = function()
            websocket_connections[connection_id].status = "closed"
            print("Connection closed")
        end,
        get_status = function()
            return websocket_connections[connection_id].status
        end
    }
end
