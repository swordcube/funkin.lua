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

function Paths.getPath(key)
    local addons = ModLoader.ADDON_LIST
    for i = 1, #addons do
        local addonAsset = ModLoader.ADDON_DIRECTORY .. "/" .. addons[i] .. "/" .. key
        if File.exists(addonAsset) then
            return addonAsset
        end
    end
    local modAsset = ModLoader.MOD_DIRECTORY .. "/" .. ModLoader.CURRENT_MOD .. "/" .. key
    if File.exists(modAsset) then
        return modAsset
    end
    return "assets/" .. key
end

function Paths.image(key, dir)
    return Paths.getPath((dir or "images") .. "/" .. key .. "." .. Constants.IMAGE_EXT)
end

function Paths.xml(key, dir)
    return Paths.getPath((dir or "data") .. "/" .. key .. ".xml")
end

function Paths.json(key, dir)
    return Paths.getPath((dir or "data") .. "/" .. key .. ".json")
end

function Paths.csv(key, dir)
    return Paths.getPath((dir or "data") .. "/" .. key .. ".csv")
end

function Paths.music(key, dir)
    return Paths.getPath((dir or "music") .. "/" .. key .. "/music." .. Constants.SOUND_EXT)
end

function Paths.sound(key, dir)
    return Paths.getPath((dir or "sounds") .. "/" .. key .. "." .. Constants.SOUND_EXT)
end

function Paths.inst(song, dir)
    return Paths.getPath((dir or "songs") .. "/" .. song:lower() .. "/song/Inst." .. Constants.SOUND_EXT)
end

function Paths.voices(song, character, dir)
    return Paths.getPath((dir or "songs") .. "/" .. song:lower() .. "/song/Voices" .. ((character and #character > 0) and ("-" .. character) or "") .. "." .. Constants.SOUND_EXT)
end

function Paths.chart(song, difficulty, dir)
    return Paths.getPath((dir or "songs") .. "/" .. song:lower() .. "/charts/" .. difficulty:lower() .. ".json")
end

function Paths.songMeta(song, dir)
    return Paths.getPath((dir or "songs") .. "/" .. song:lower() .. "/meta.json")
end

function Paths.font(key, dir)
    return Paths.getPath((dir or "fonts") .. "/" .. key)
end

function Paths.getSparrowAtlas(key, dir)
    local imgPath = Paths.image(key, (dir or "images"))
    local xmlPath = Paths.xml(key, (dir or "images"))

    local cache = Cache.atlasCache
    local atlasKey = "#_SPARROW_" .. imgPath .. "|" .. xmlPath
    
    if not cache[atlasKey] then
        cache[atlasKey] = AtlasFrames.fromSparrow(imgPath, xmlPath)
        cache[atlasKey]:reference()
    end
    return cache[atlasKey]
end

return Paths