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

local AtlasFrames = crequire("animation.frames.AtlasFrames") --- @type chip.animation.frames.AtlasFrames

---
--- @class funkin.backend.Paths
---
local Paths = {}

Paths.currentMod = nil

function Paths.getPath(key, mod, type)
    if not mod then
        mod = Paths.currentMod
    end
    if not type then
        type = "getPath"
    end
    local modPaths = ModLoader.modPaths
    local modFolders = ModLoader.modFolders

    if mod ~= nil and #mod > 0 then
        if modPaths[mod] and modPaths[mod][type] then
            local p = modPaths[mod][type](key, mod)
            if p then
                return p
            end
        end
        local modAsset = ModLoader.modDirectory .. "/" .. modFolders[mod] .. "/" .. key
        if File.exists(modAsset) then
            return modAsset
        end
    else
        local modList = ModLoader.modList
        for i = 1, #modList do
            local mod = modList[i]
            if not Options.enabledMods[mod] then
                goto continue
            end
            if modPaths[mod] and modPaths[mod][type] then
                local p = modPaths[mod][type](key, mod)
                if p and File.fileExists(p) then
                    return p
                end
            end
            local modAsset = ModLoader.modDirectory .. "/" .. modFolders[mod] .. "/" .. key
            if File.exists(modAsset) then
                return modAsset
            end
            ::continue::
        end
    end
    return "assets/" .. key
end

function Paths.image(key, mod)
    return Paths.getPath("images/" .. key .. "." .. Constants.IMAGE_EXT, mod, "image")
end

function Paths.xml(key, mod)
    return Paths.getPath(key .. ".xml", mod, "xml")
end

function Paths.json(key, mod)
    return Paths.getPath(key .. ".json", mod, "json")
end

function Paths.csv(key, mod)
    return Paths.getPath(key .. ".csv", mod, "csv")
end

function Paths.music(key, mod)
    return Paths.getPath("music/" .. key .. "/music." .. Constants.SOUND_EXT, mod, "music")
end

function Paths.sound(key, mod)
    return Paths.getPath("sounds/" .. key .. "." .. Constants.SOUND_EXT, mod, "sound")
end

function Paths.inst(song, mod)
    return Paths.getPath("songs/" .. song:lower() .. "/song/Inst." .. Constants.SOUND_EXT, mod, "inst")
end

function Paths.voices(song, character, mod)
    return Paths.getPath("songs/" .. song:lower() .. "/song/Voices" .. ((character and #character > 0) and ("-" .. character) or "") .. "." .. Constants.SOUND_EXT, mod, "voices")
end

function Paths.chart(song, difficulty, mod)
    return Paths.getPath("songs/" .. song:lower() .. "/charts/" .. difficulty:lower() .. ".json", mod, "chart")
end

function Paths.songMeta(song, mod)
    return Paths.getPath("songs/" .. song:lower() .. "/meta.json", mod, "songMeta")
end

function Paths.stage(stage, mod)
    return Paths.getPath("data/stages/" .. stage .. ".json", mod, "stage")
end

function Paths.character(character, mod)
    return Paths.getPath("data/characters/" .. character .. ".json", mod, "character")
end

function Paths.musicMeta(key, mod)
    return Paths.getPath("music/" .. key .. "/meta.json", mod, "musicMeta")
end

function Paths.font(key, mod)
    return Paths.getPath("fonts/" .. key, mod, "font")
end

function Paths.frag(key, mod)
    return Paths.getPath("shaders/" .. key .. ".frag", mod, "frag")
end

function Paths.vert(key, mod)
    return Paths.getPath("shaders/" .. key .. ".vert", mod, "vert")
end

function Paths.noteSkin(key, mod)
    return Paths.getPath("data/noteskins/" .. key .. ".json", mod, "noteSkin")
end

function Paths.uiSkin(key, mod)
    return Paths.getPath("data/uiskins/" .. key .. ".json", mod, "uiSkin")
end

function Paths.getSparrowAtlas(key, mod)
    local imgPath = Paths.image(key, mod)
    local xmlPath = Paths.xml("images/" .. key, mod)

    local cache = Cache.atlasCache
    local atlasKey = "#_SPARROW_" .. imgPath .. "|" .. xmlPath
    
    if not cache[atlasKey] then
        cache[atlasKey] = AtlasFrames.fromSparrow(imgPath, xmlPath)
    end
    return cache[atlasKey]
end

return Paths