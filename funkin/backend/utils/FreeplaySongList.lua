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

local SongMetadata = require("funkin.backend.song.SongMetadata") --- @type funkin.backend.song.SongMetadata

---
--- @class funkin.backend.utils.FreeplaySongList
---
local FreeplaySongList = {}

---
--- @return table
---
function FreeplaySongList.get()
    local songList = {}
    local levelLists = {}
    tblInsert(levelLists, {
        data = Json.parse(File.read("assets/data/levelList.json")),
        mod = "",
        directory = "assets/data/levels"
    })
    local modList = ModLoader.modList
    local modFolders = ModLoader.modFolders

    for i = 1, #modList do
        if not Options.enabledMods[modList[i]] then
            goto modContinue
        end
        local modLevelListPath = ModLoader.modDirectory .. "/" .. modFolders[modList[i]] .. "/data/levelList.json"
        if File.fileExists(modLevelListPath) then
            local leData = Json.parse(File.read(modLevelListPath))
            if leData.mode:lower() == "replace" then
                levelLists = {}
            end
            tblInsert(levelLists, {
                data = leData,
                mod = modList[i],
                directory = ModLoader.modDirectory .. "/" .. modFolders[modList[i]] .. "/data/levels"
            })
        end
        ::modContinue::
    end
    for a = 1, #levelLists do
        local levelList = levelLists[a]
        for i = 1, #levelList.data.levels do
            -- go through each level
            local levelData = LevelRegistry.instance:getEntry(levelList.data.levels[i], levelList.mod)
            if not levelData then
                -- if it doesn't exist, try to load without mod
                levelData = LevelRegistry.instance:getEntry(levelList.data.levels[i])
            end
            if not levelData then
                -- if it doesn't exist, skip
                goto levelContinue
            end
            for j = 1, #levelData.songs do
                -- go through each song in this level
                local songID = levelData.songs[j] --- @type string
    
                local songMeta = SongRegistry.instance:getEntry(songID, levelList.mod) --- @type funkin.backend.song.SongMetadata?
                if not songMeta then
                    -- if it doesn't exist, try to load without mod
                    songMeta = SongRegistry.instance:getEntry(songID)
                end
                if not songMeta then
                    -- if it doesn't exist, skip
                    goto songContinue
                end
                if not songMeta.color then
                    songMeta.color = "#FFFFFF"
                end
                songMeta._parsedColor = Color:new(songMeta.color)
                
                local data = {
                    default = songMeta
                }
                for k = 1, #songMeta.variants do
                    -- go through each variant
                    local variant = songMeta.variants[k] --- @type string
                    local variantMeta = SongRegistry.instance:getEntry(songID .. "-" .. variant, levelList.mod) --- @type funkin.backend.song.SongMetadata?
                    
                    if variantMeta then
                        if not variantMeta.color then
                            variantMeta.color = "#FFFFFF"
                        end
                        variantMeta._parsedColor = Color:new(variantMeta.color)
    
                        -- if it exists, add it
                        data[variant] = variantMeta
                    end
                end
                tblInsert(songList, {
                    id = songID,
                    metas = data,
                    mod = levelList.mod
                })
                ::songContinue::
            end
            ::levelContinue::
        end
    end
    return songList
end

return FreeplaySongList