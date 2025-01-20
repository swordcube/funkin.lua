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

local UISkin = require("funkin.backend.data.UISkin") --- @type funkin.backend.data.UISkin

---
--- @class funkin.gameplay.Countdown
---
local Countdown = {}

Countdown.timer = nil --- @type chip.utils.Timer

---
--- @param  uiSkin     string
--- @param  conductor  funkin.backend.Conductor?
--- @param  callback   function?
---
function Countdown.start(uiSkin, conductor, callback)
    local json = UISkin.get(uiSkin) --- @type funkin.backend.data.UISkin?
    Countdown._uiSkin = json

    if not conductor then
        conductor = Conductor.instance
    end
    local sounds = {} --- @type table<chip.audio.AudioPlayer>
    local soundIDs = json.countdown.sounds
    for i = 1, #soundIDs do
        local sound = AudioPlayer:new() --- @type chip.audio.AudioPlayer
        sound:load(Paths.sound(json.countdown.soundFolder .. "/" .. soundIDs[i]))
        table.insert(sounds, sound)
    end
    local swagCounter = 1
    if Countdown.timer then
        Countdown.timer:free()
    end
    Countdown.timer = Timer:new()
    Countdown.timer:start(conductor:getCrotchet() / 1000, function(tmr)
        local sprite = Sprite:new() --- @type chip.graphics.Sprite
        if json.countdown.atlasType == "sparrow" then
            sprite:setFrames(Paths.getSparrowAtlas(json.countdown.textureFolder .. "/" .. json.countdown.texture))
            for i = 1, #json.countdown.animations do
                local animData = json.countdown.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
                if animData.indices and #animData.indices > 0 then
                    sprite.animation:addByIndices(animData.name, animData.prefix, animData.indices, animData.fps, animData.looped)
                else
                    sprite.animation:addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped)
                end
            end
        elseif json.countdown.atlasType == "grid" then
            sprite:loadTexture(Paths.image(json.countdown.textureFolder .. "/" .. json.countdown.texture), true, json.countdown.gridSize.x, json.countdown.gridSize.y)
            for i = 1, #json.countdown.animations do
                local animData = json.countdown.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
                sprite.animation:add(animData.name, animData.indices, animData.fps, animData.looped)
            end
        
        elseif json.countdown.atlasType == "animate" then
            -- TODO
        end
        sprite.scale:set(json.countdown.scale, json.countdown.scale)
        sprite:screenCenter("xy")

        sprite.scrollFactor:set()
        sprite.animation:play(json.countdown.animations[swagCounter].name)

        local sound = sounds[swagCounter] --- @type chip.audio.AudioPlayer
        Engine.currentScene:add(sound)

        local t = Tween:new() --- @type chip.tweens.Tween
        t:tweenProperty(sprite, "alpha", 0, conductor:getCrotchet() / 1000):setEase(Ease.cubeInOut)
        t:setCompletionCallback(function(_)
            sprite:free()
        end)
        if callback then
            callback(sprite, sound, t, swagCounter)
        end
        swagCounter = swagCounter + 1

        if tmr:getLoopsLeft() == 0 then
            Countdown.timer = nil
        end
    end, #json.countdown.sounds)
end

return Countdown