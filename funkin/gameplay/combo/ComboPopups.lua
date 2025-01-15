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

local function killActor(a)
    a:kill()
end
local abs = math.abs

local UISkin = require("funkin.backend.data.UISkin") --- @type funkin.backend.data.UISkin\
local ComboSprite = require("funkin.gameplay.combo.ComboSprite") --- @type funkin.gameplay.combo.ComboSprite

---
--- @class funkin.gameplay.combo.ComboPopups : chip.graphics.CanvasLayer
---
local ComboPopups = CanvasLayer:extend("ComboPopups", ...)

function ComboPopups:constructor(x, y, defaultSkin)
    ComboPopups.super.constructor(self, x, y)

    self.defaultSkin = defaultSkin or "default"

    for i = 1, 16 do
        local sprite = ComboSprite:new() --- @type funkin.gameplay.combo.ComboSprite
        sprite:setJudgementSkin(self.defaultSkin)
        sprite:setComboSkin(self.defaultSkin)
        sprite:kill()
        self:add(sprite)
    end
end

function ComboPopups:killAllSprites()
    self:forEachExisting(killActor)
end

---
--- @param  judgement  string
--- @param  skin       string
--- 
--- @return funkin.gameplay.combo.ComboSprite
---
function ComboPopups:showJudgement(judgement, skin)
    local sprite = self:recycle(ComboSprite) --- @type funkin.gameplay.combo.ComboSprite
    sprite:setAlpha(1.0)
    sprite:setTint(Color.WHITE)

    sprite:setPosition(Engine.gameWidth * 0.474, (Engine.gameHeight * 0.45) - 60)
    sprite:setRotation(0.0)

    sprite:setJudgementSkin(skin)
    sprite.animation:play(judgement)

    local json = UISkin.get(skin) --- @type funkin.backend.data.UISkin?
    sprite.scale:set(json.judgements.scale * 0.95, json.judgements.scale * 0.95)

    if json.judgements.antialiasing ~= nil then
        sprite:setAntialiasing(json.judgements.antialiasing)
    else
        sprite:setAntialiasing(true)
    end
    sprite:setPosition(sprite:getX() - (sprite:getWidth() * 0.5), sprite:getY() - (sprite:getHeight() * 0.5))

    sprite.acceleration.y = 550
    sprite.velocity:set(-math.random(0, 10), -math.random(140, 175))

    if sprite._tween then
        sprite._tween:free()
    end
    local t = Tween:new() --- @type chip.tweens.Tween
    t:tweenProperty(sprite, "scale", Point:new(json.judgements.scale, json.judgements.scale), 0.1)
    t:tweenProperty(sprite, "alpha", 0, 0.2):setStartDelay(Conductor.instance:getCrotchet() * 0.001)
    t:setCompletionCallback(function(_)
        sprite._tween = nil
        sprite:kill()
    end)
    sprite._tween = t

    self:remove(sprite)
    self:add(sprite)

    return sprite
end

---
--- @param  combo  integer
--- @param  skin   string
--- @param  miss?  boolean
---
function ComboPopups:showCombo(combo, skin, miss)
    local separatedCombo = tostring(abs(combo))
    while #separatedCombo < 3 do
        separatedCombo = "0" .. separatedCombo
    end
    if combo < 0 then
        separatedCombo = "-" .. separatedCombo
    end
    local digitCount = #separatedCombo
    for i = 1, digitCount do
        local sprite = self:recycle(ComboSprite) --- @type funkin.gameplay.combo.ComboSprite
        sprite:setAlpha(1.0)
        sprite:setTint(miss and 0xFFb73c3c or Color.WHITE)

        sprite:setPosition((Engine.gameWidth * 0.507) - (36 * (i - 1)) - 65, (Engine.gameHeight * 0.5) - 60)
        sprite:setRotation(0.0)

        sprite:setComboSkin(skin)
        sprite.animation:play(separatedCombo:charAt(digitCount - (i - 1)))

        local json = UISkin.get(skin) --- @type funkin.backend.data.UISkin?
        sprite.scale:set(json.combo.scale * 0.95, json.combo.scale * 0.95)

        if json.combo.antialiasing ~= nil then
            sprite:setAntialiasing(json.combo.antialiasing)
        else
            sprite:setAntialiasing(true)
        end
        sprite.acceleration.y = math.random(200, 300)
        sprite.velocity:set(math.random(-5.0, 5.0), -math.random(140, 160))

        if sprite._tween then
            sprite._tween:free()
        end
        local t = Tween:new() --- @type chip.tweens.Tween
        t:tweenProperty(sprite, "scale", Point:new(json.combo.scale, json.combo.scale), 0.1)
        t:tweenProperty(sprite, "alpha", 0, 0.2):setStartDelay(Conductor.instance:getCrotchet() * 0.002)
        t:setCompletionCallback(function(_)
            sprite._tween = nil
            sprite:kill()
        end)
        sprite._tween = t

        self:remove(sprite)
        self:add(sprite)
    end
end

return ComboPopups