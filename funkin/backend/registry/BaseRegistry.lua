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

local tblInsert = table.insert

---
--- @class funkin.backend.registry.BaseRegistry
---
local BaseRegistry = Class:extend("BaseRegistry", ...)

function BaseRegistry:constructor()
    ---
    --- @protected
    ---
    self._entries = {} --- @type table<string, any>
end

function BaseRegistry:getEntryIDs()
    local ids = {}
    for key, _ in pairs(self._entries) do
        tblInsert(ids, key)
    end
    return ids
end

function BaseRegistry:getEntryCount()
    local count = 0
    for _, _ in pairs(self._entries) do
        count = count + 1
    end
    return count
end

function BaseRegistry:clearEntries()
    self._entries = {}
end

---
--- @param  id  string
--- @return any
---
function BaseRegistry:getEntry(id)
    return self._entries[id]
end

---
--- @param  id    string  ID of the entry to register.
--- @param  data  any     Data of the new entry.
---
function BaseRegistry:registerEntry(id, data)
    self._entries[id] = data
end

return BaseRegistry