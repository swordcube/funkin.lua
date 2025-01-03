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
local tblRemove = table.remove
local tblContains = table.contains

local Script = require("funkin.backend.Script") --- @type funkin.backend.Script

---
--- @class funkin.backend.ModLoader
---
local ModLoader = {}

ModLoader.modList = {}
ModLoader.modDirectory = "mods"
ModLoader.currentMod = "test"
ModLoader.loadedMainScripts = {}

function ModLoader.init()
    ModLoader.updateModList()
    ModLoader.reloadMainScripts()

    Engine.preUpdate:connect(function()
        local loadedMainScripts = ModLoader.loadedMainScripts
        for i = 1, #loadedMainScripts do
            script = loadedMainScripts[i] --- @type funkin.backend.Script
            script:callMethod("update", {Engine.deltaTime})
            script:callMethod("preUpdate", {Engine.deltaTime})
        end
    end)
    Engine.postUpdate:connect(function()
        local loadedMainScripts = ModLoader.loadedMainScripts
        for i = 1, #loadedMainScripts do
            script = loadedMainScripts[i] --- @type funkin.backend.Script
            script:callMethod("postUpdate", {Engine.deltaTime})
        end
    end)
    Engine.preDraw:connect(function()
        local loadedMainScripts = ModLoader.loadedMainScripts
        for i = 1, #loadedMainScripts do
            script = loadedMainScripts[i] --- @type funkin.backend.Script
            script:callMethod("preDraw")
        end
    end)
    Engine.postDraw:connect(function()
        local loadedMainScripts = ModLoader.loadedMainScripts
        for i = 1, #loadedMainScripts do
            script = loadedMainScripts[i] --- @type funkin.backend.Script
            script:callMethod("postDraw")
        end
    end)
    Engine.preSceneDraw:connect(function()
        local loadedMainScripts = ModLoader.loadedMainScripts
        for i = 1, #loadedMainScripts do
            script = loadedMainScripts[i] --- @type funkin.backend.Script
            script:callMethod("preSceneDraw")
        end
    end)
    Engine.postSceneDraw:connect(function()
        local loadedMainScripts = ModLoader.loadedMainScripts
        for i = 1, #loadedMainScripts do
            script = loadedMainScripts[i] --- @type funkin.backend.Script
            script:callMethod("postSceneDraw")
        end
    end)
    Engine.onFocusGained:connect(function()
        local loadedMainScripts = ModLoader.loadedMainScripts
        for i = 1, #loadedMainScripts do
            script = loadedMainScripts[i] --- @type funkin.backend.Script
            script:callMethod("onFocusGained")
        end
    end)
    Engine.onFocusLost:connect(function()
        local loadedMainScripts = ModLoader.loadedMainScripts
        for i = 1, #loadedMainScripts do
            script = loadedMainScripts[i] --- @type funkin.backend.Script
            script:callMethod("onFocusLost")
        end
    end)
    Engine.onWindowResize:connect(function(w, h)
        local loadedMainScripts = ModLoader.loadedMainScripts
        for i = 1, #loadedMainScripts do
            script = loadedMainScripts[i] --- @type funkin.backend.Script
            script:callMethod("onWindowResize", {w, h})
        end
    end)
    Engine.onInputReceived:connect(function(e)
        local loadedMainScripts = ModLoader.loadedMainScripts
        for i = 1, #loadedMainScripts do
            script = loadedMainScripts[i] --- @type funkin.backend.Script
            script:callMethod("onInputReceived", {e})
        end
    end)
end

---
--- Updates the mod list with every available mod.
---
function ModLoader.updateModList()
    local newModsDetected = 0
    ModLoader.modList = Options.savedMods

    local list = ModLoader.modList
    local directory = ModLoader.modDirectory

    local scannedList = {}
    if fs.getInfo(directory, "directory") then
        local dirItems = fs.getDirectoryItems(directory)
        for i = 1, #dirItems do
            local item = dirItems[i]
            if fs.getInfo(directory .. "/" .. item, "directory") then
                if not tblContains(list, item) then
                    newModsDetected = newModsDetected + 1
                    Options.enabledMods[item] = true
                    tblInsert(list, item)
                end
                tblInsert(scannedList, item)
            end
        end
    end
    for i = 1, #list do
        if not tblContains(scannedList, list[i]) then
            Options.enabledMods[list[i]] = nil
            tblRemove(list, i)
        end
    end
    if newModsDetected > 0 then
        print("Detected " .. newModsDetected .. " new mod" .. (newModsDetected == 1 and "" or "s"))
        Options.save()
    end
    print("Detected " .. #list .. " mod" .. (#list == 1 and "" or "s"))
end

---
--- Reloads the main script for every mod.
---
function ModLoader.reloadMainScripts()
    local loadedMainScripts = ModLoader.loadedMainScripts
    for i = 1, #loadedMainScripts do
        local script = loadedMainScripts[i] --- @type funkin.backend.Script
        script:close()
    end
    ModLoader.loadedMainScripts = {}
    
    local modList = ModLoader.modList
    for i = 1, #modList do
        local script = Script:new(ModLoader.modDirectory .. "/" .. modList[i] .. "/main.lua") --- @type funkin.backend.Script
        if not script:isClosed() then
            tblInsert(ModLoader.loadedMainScripts, script)
        end
    end
    local script = Script:new("assets/main.lua") --- @type funkin.backend.Script
    if not script:isClosed() then
        tblInsert(ModLoader.loadedMainScripts, script)
    end
    local loadedMainScripts = ModLoader.loadedMainScripts
    for i = 1, #loadedMainScripts do
        script = loadedMainScripts[i] --- @type funkin.backend.Script
        script:callMethod("init")
    end
end

return ModLoader