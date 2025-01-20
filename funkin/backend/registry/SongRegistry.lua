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
local tblContains = table.contains

---
--- @class funkin.backend.registry.SongRegistry : funkin.backend.registry.BaseRegistry
---
local SongRegistry = BaseRegistry:extend("SongRegistry", ...)

SongRegistry.instance = SongRegistry:new() --- @type funkin.backend.registry.SongRegistry

---
--- @param  id    string
--- @param  mod?  string
--- 
--- @return funkin.backend.song.SongMetadata
---
function SongRegistry:getEntry(id, mod)
    if not mod then
        mod = Paths.currentMod
    end
    if mod and #mod ~= 0 then
        return self._entries[id .. "-" .. mod]
    end
    return self._entries[id]
end

---
--- @param  id    string                            ID of the entry to register.
--- @param  data  funkin.backend.song.SongMetadata  Data of the new entry.
--- @param  mod   string?                           Mod of the entry to register.
---
function SongRegistry:registerEntry(id, data, mod)
    if not tblContains(data.variants, "default") then
        tblInsert(data.variants, 1, "default")
    end
    if not mod or #mod == 0 then
        mod = Paths.currentMod
    end
    if mod then
        self._entries[id .. "-" .. mod] = data
    end
    self._entries[id] = data
end

return SongRegistry