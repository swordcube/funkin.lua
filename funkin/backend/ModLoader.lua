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
local tblInsert = table.insert

---
--- @class funkin.backend.ModLoader
---
local ModLoader = {}

ModLoader.MOD_LIST = {}
ModLoader.MOD_DIRECTORY = "mods"

ModLoader.ADDON_LIST = {}
ModLoader.ADDON_DIRECTORY = "addons"

ModLoader.CURRENT_MOD = "test"

function ModLoader.init()
    ModLoader.updateModList()
    ModLoader.updateAddonList()
end

---
--- Updates the mod list with every available mod.
---
function ModLoader.updateModList()
    local list = ModLoader.MOD_LIST
    local directory = ModLoader.MOD_DIRECTORY

    if fs.getInfo(directory, "directory") then
        local dirItems = fs.getDirectoryItems(directory)
        for i = 1, #dirItems do
            local item = dirItems[i]
            if fs.getInfo(directory .. "/" .. item, "directory") then
                tblInsert(list, item)
            end
        end
    end
    print("Detected " .. #ModLoader.MOD_LIST .. " mod" .. (#ModLoader.MOD_LIST == 1 and "" or "s"))
end

---
--- Updates the addon list with every available addon.
---
function ModLoader.updateAddonList()
    local list = ModLoader.ADDON_LIST
    local directory = ModLoader.ADDON_DIRECTORY

    if fs.getInfo(directory, "directory") then
        local dirItems = fs.getDirectoryItems(directory)
        for i = 1, #dirItems do
            local item = dirItems[i]
            if fs.getInfo(directory .. "/" .. item, "directory") then
                tblInsert(list, item)
            end
        end
    end
    print("Detected " .. #ModLoader.ADDON_LIST .. " addon" .. (#ModLoader.ADDON_LIST == 1 and "" or "s"))
end

return ModLoader