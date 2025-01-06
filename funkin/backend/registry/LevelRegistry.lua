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
--- @class funkin.backend.registry.LevelRegistry : funkin.backend.registry.BaseRegistry
---
local LevelRegistry = BaseRegistry:extend("LevelRegistry", ...)

LevelRegistry.instance = LevelRegistry:new() --- @type funkin.backend.registry.LevelRegistry

---
--- @param  id    string
--- @param  mod?  string
--- 
--- @return funkin.backend.data.LevelData
---
function LevelRegistry:getEntry(id, mod)
    if not mod then
        mod = Paths.currentMod
    end
    if mod then
        return self._entries[id .. "-" .. mod]
    end
    return self._entries[id]
end

---
--- @param  id    string                         ID of the entry to register.
--- @param  data  funkin.backend.data.LevelData  Data of the new entry.
--- @param  mod   string?                        Mod of the new entry.
---
function LevelRegistry:registerEntry(id, data)
    if not mod then
        mod = Paths.currentMod
    end
    if mod then
        self._entries[id .. "-" .. mod] = data
    end
    self._entries[id] = data
end

return LevelRegistry