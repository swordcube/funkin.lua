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

function Paths.getPath(key, mod)
    if not mod then
        mod = Paths.currentMod
    end
    if mod then
        local modAsset = ModLoader.modDirectory .. "/" .. mod .. "/" .. key
        if File.exists(modAsset) then
            return modAsset
        end
    else
        local modList = ModLoader.modList
        for i = 1, #modList do
            local mod = modList[i]
            if Options.enabledMods[mod] then
                local modAsset = ModLoader.modDirectory .. "/" .. mod .. "/" .. key
                if File.exists(modAsset) then
                    return modAsset
                end
            end
        end
    end
    return "assets/" .. key
end

function Paths.image(key, dir, mod)
    return Paths.getPath((dir or "images") .. "/" .. key .. "." .. Constants.IMAGE_EXT, mod)
end

function Paths.xml(key, dir, mod)
    return Paths.getPath((dir or "data") .. "/" .. key .. ".xml", mod)
end

function Paths.json(key, dir, mod)
    return Paths.getPath((dir or "data") .. "/" .. key .. ".json", mod)
end

function Paths.csv(key, dir, mod)
    return Paths.getPath((dir or "data") .. "/" .. key .. ".csv", mod)
end

function Paths.music(key, dir, mod)
    return Paths.getPath((dir or "music") .. "/" .. key .. "/music." .. Constants.SOUND_EXT, mod)
end

function Paths.sound(key, dir, mod)
    return Paths.getPath((dir or "sounds") .. "/" .. key .. "." .. Constants.SOUND_EXT, mod)
end

function Paths.inst(song, dir, mod)
    return Paths.getPath((dir or "songs") .. "/" .. song:lower() .. "/song/Inst." .. Constants.SOUND_EXT, mod)
end

function Paths.voices(song, character, dir, mod)
    return Paths.getPath((dir or "songs") .. "/" .. song:lower() .. "/song/Voices" .. ((character and #character > 0) and ("-" .. character) or "") .. "." .. Constants.SOUND_EXT, mod)
end

function Paths.chart(song, difficulty, dir, mod)
    return Paths.getPath((dir or "songs") .. "/" .. song:lower() .. "/charts/" .. difficulty:lower() .. ".json", mod)
end

function Paths.songMeta(song, dir, mod)
    return Paths.getPath((dir or "songs") .. "/" .. song:lower() .. "/meta.json", mod)
end

function Paths.font(key, dir, mod)
    return Paths.getPath((dir or "fonts") .. "/" .. key, mod)
end

function Paths.frag(key, dir, mod)
    return Paths.getPath((dir or "shaders") .. "/" .. key .. ".frag", mod)
end

function Paths.vert(key, dir, mod)
    return Paths.getPath((dir or "shaders") .. "/" .. key .. ".vert", mod)
end

function Paths.getSparrowAtlas(key, dir, mod)
    local imgPath = Paths.image(key, (dir or "images"), mod)
    local xmlPath = Paths.xml(key, (dir or "images"), mod)

    local cache = Cache.atlasCache
    local atlasKey = "#_SPARROW_" .. imgPath .. "|" .. xmlPath
    
    if not cache[atlasKey] then
        cache[atlasKey] = AtlasFrames.fromSparrow(imgPath, xmlPath)
    end
    return cache[atlasKey]
end

return Paths