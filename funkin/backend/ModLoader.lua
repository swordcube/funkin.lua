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

    local function callOnMainScripts(method, args)
        local oldMod = Paths.currentMod
        Paths.currentMod = ModLoader.currentMod

        local loadedMainScripts = ModLoader.loadedMainScripts
        for i = 1, #loadedMainScripts do
            script = loadedMainScripts[i] --- @type funkin.backend.Script
            script:callMethod(method, args)
        end
        Paths.currentMod = oldMod
    end
    Engine.preUpdate:connect(function()
        callOnMainScripts("onUpdate", {Engine.deltaTime})
    end)
    Engine.postUpdate:connect(function()
        callOnMainScripts("onPostUpdate", {Engine.deltaTime})
    end)
    Engine.preDraw:connect(function()
        callOnMainScripts("onDraw")
    end)
    Engine.postDraw:connect(function()
        callOnMainScripts("onPostDraw")
    end)
    Engine.preSceneDraw:connect(function()
        callOnMainScripts("onSceneDraw")
    end)
    Engine.postSceneDraw:connect(function()
        callOnMainScripts("onPostSceneDraw")
    end)
    Engine.onFocusGained:connect(function()
        callOnMainScripts("onFocusGained")
    end)
    Engine.onFocusLost:connect(function()
        callOnMainScripts("onFocusLost")
    end)
    Engine.onWindowResize:connect(function(w, h)
        callOnMainScripts("onWindowResize", {w, h})
    end)
    Engine.onInputReceived:connect(function(e)
        callOnMainScripts("onInputReceived", {e})
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
--- Refreshes all imports/requires, for scene/script reloading.
---
function ModLoader.refreshImports()
    local disallowedKeys = {
        "funkin.backend.*",
        "funkin.gameplay.GameplaySettings",
        "funkin.ui.SoundTray"
    }
    local packagesToRemove = {}
    for key, value in pairs(package.loaded) do
        if not key:startsWith("funkin") then
            goto continue
        end
        for i = 1, #disallowedKeys do
            local disallowedKey = disallowedKeys[i] --- @type string
            if disallowedKey:endsWith(".*") and key:startsWith(disallowedKey:sub(1, #disallowedKey - 2)) then
                goto continue
            
            elseif key == disallowedKey then
                goto continue
            end
        end
        packagesToRemove[key] = value
        ::continue::
    end
    for key, value in pairs(packagesToRemove) do
        package.loaded[key] = nil
        collectgarbage("collect")

        for key2, value2 in pairs(_G) do
            if value2 == value then
                _G[key2] = require(key)
                break
            end
        end
    end
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
    
    local oldMod = Paths.currentMod
    local modList = ModLoader.modList
    for i = 1, #modList do
        Paths.currentMod = ModLoader.currentMod
        local script = Script:new(ModLoader.modDirectory .. "/" .. modList[i] .. "/main.lua") --- @type funkin.backend.Script
        if not script:isClosed() then
            tblInsert(ModLoader.loadedMainScripts, script)
            script:callMethod("init")
        end
    end
    Paths.currentMod = oldMod
    
    local script = Script:new("assets/main.lua") --- @type funkin.backend.Script
    if not script:isClosed() then
        tblInsert(ModLoader.loadedMainScripts, script)
        script:callMethod("init")
    end
end

return ModLoader