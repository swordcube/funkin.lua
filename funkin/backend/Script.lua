--[[
    Copyright 2024 swordcube

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

local fs = love.filesystem
local unpack = table.unpack

---
--- @class funkin.backend.Script
---
local Script = Class:extend("Script", ...)

function Script:constructor(filePath)
    self._filePath = filePath
    self._variables = {}
    self._closed = false
    
    local vars = self._variables
    vars.close = function()
        self:close()
    end
    local success, err = pcall(function()
        local chunk = fs.load(filePath)
        if chunk then
            local env = {Script = Script}
            for k, f in pairs(_G) do
                env[k] = f
            end
            env._G = _G
            setfenv(chunk, setmetatable(vars, {__index = env}))
            chunk()
        end
    end)
    if not success then
        self:close()
        Log.error(nil, nil, nil, "Failed to load script at " .. self._filePath .. ": " .. err)
    end
end

function Script:getFilePath()
    return self._filePath
end

function Script:getAllVariables()
    return self._variables
end

function Script:isClosed()
    return self._closed
end

function Script:getVariable(var)
    return self._variables[var]
end

function Script:setVariable(var, val)
    self._variables[var] = val
end

function Script:callMethod(method, args)
    local f = self._variables[method]
    if type(f) == "function" then
        if args == nil then
            return f()
        end
        return f(unpack(args))
    end
    return nil
end

function Script:close()
    local chunk = self.chunk
    if chunk then
        local onClose = self._variables.onClose
        if onClose then
            onClose()
        end
        setfenv(chunk, setmetatable({}, {
            __index = function() error("Tried to use a closed script") end,
            __newindex = function() error("Tried to use a closed script") end,
        }))
    end
    self._variables = nil
    self._closed = true
end

return Script