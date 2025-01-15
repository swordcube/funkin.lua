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

local lerp = math.lerp
local random = math.random

local floor = math.floor

local min = math.min
local max = math.max

local tblContains = table.contains

-- TODO: Clean this up later
-- This is just a port of the one from legacy branch,
-- just suited for chip instead of flora

---
--- @class funkin.ui.SoundTray
--- 
--- A tray used for changing the master volume,
--- typically triggered by pressing +, -, or 0 on the keyboard.
--- 
--- Those keys can be rebinded in the controls menu!
---
local SoundTray = {}

function SoundTray.init()
    Engine.postUpdate:connect(function()
        SoundTray.update(Engine.deltaTime)
    end)
    Engine.postDraw:connect(SoundTray.draw)
    Engine.onInputReceived:connect(SoundTray.input)

    SoundTray._volumeUpKeys = {KeyCode.EQUALS, KeyCode.NUMPAD_PLUS}
    SoundTray._volumeDownKeys = {KeyCode.MINUS, KeyCode.NUMPAD_MINUS}
    SoundTray._muteKeys = {KeyCode.ZERO, KeyCode.NUMPAD_ZERO}

    SoundTray.box = love.graphics.newImage(Paths.image("volumebox", "images/volume"))
    SoundTray.box:setFilter("linear", "linear")
    
    SoundTray.alpha = 0.0

    ---
    --- @type chip.math.Point
    ---
    SoundTray.scale = Point:new(0.6, 0.6)

    SoundTray.width = SoundTray.box:getWidth() * SoundTray.scale.x
    SoundTray.height = SoundTray.box:getHeight() * SoundTray.scale.y

    SoundTray.y = -(SoundTray.height + 10)

    SoundTray.offsetX = 0.0
    SoundTray.offsetY = 0.0

    SoundTray._timer = math.huge
    SoundTray._shakeMult = 0.0

    SoundTray.bars = {
        love.graphics.newImage(Paths.image("bars_1", "images/volume")),
        love.graphics.newImage(Paths.image("bars_2", "images/volume")),
        love.graphics.newImage(Paths.image("bars_3", "images/volume")),
        love.graphics.newImage(Paths.image("bars_4", "images/volume")),
        love.graphics.newImage(Paths.image("bars_5", "images/volume")),
        love.graphics.newImage(Paths.image("bars_6", "images/volume")),
        love.graphics.newImage(Paths.image("bars_7", "images/volume")),
        love.graphics.newImage(Paths.image("bars_8", "images/volume")),
        love.graphics.newImage(Paths.image("bars_9", "images/volume")),
        love.graphics.newImage(Paths.image("bars_10", "images/volume")),
    }
    for i = 1, #SoundTray.bars do
        ---
        --- @type love.Image
        ---
        local bar = SoundTray.bars[i]
        bar:setFilter("linear", "linear")
    end
    SoundTray.anims = {
        adjust = {
            fps = 18,
            frames = {
                Point:new(0.62, 0.58),
                Point:new(0.6, 0.6),
            }
        }
    }
    SoundTray.curAnim = "adjust"
    SoundTray.curFrame = #SoundTray.anims[SoundTray.curAnim].frames

    SoundTray._elapsedAnimTime = 0.0
end

function SoundTray.show(up)
    SoundTray.visible = true
    SoundTray._timer = 0.0

    local masterVolume = AudioBus.master:getVolume()
    if not (up and masterVolume >= 1.0) then
        SoundTray.curAnim = "adjust"
        SoundTray.curFrame = 1

        SoundTray._elapsedAnimTime = 0.0
    end
    if up then
        if masterVolume >= 1.0 then
            SoundTray._shakeMult = 1.0
            AudioPlayer.playSFX("assets/sounds/volume/max.ogg")
        else
            AudioPlayer.playSFX("assets/sounds/volume/up.ogg")
        end
    else
        AudioPlayer.playSFX("assets/sounds/volume/down.ogg")
    end
end

function SoundTray.update(dt)
    local curAnim = SoundTray.anims[SoundTray.curAnim]
    SoundTray.scale:set(
        curAnim.frames[SoundTray.curFrame].x,
        curAnim.frames[SoundTray.curFrame].y
    )
    SoundTray.width = SoundTray.box:getWidth() * SoundTray.scale.x
    SoundTray.height = SoundTray.box:getHeight() * SoundTray.scale.y

    SoundTray._timer = SoundTray._timer + dt
    
    if SoundTray._timer > 1.5 then
        SoundTray.y = lerp(SoundTray.y, -(SoundTray.height + 20), dt * 9.0)
        SoundTray.alpha = lerp(SoundTray.alpha, 0.0, dt * 9.0)

        if SoundTray.y <= -SoundTray.height then
            SoundTray.visible = false
        end
    else
        SoundTray.y = lerp(SoundTray.y, 10, dt * 9.0)
        SoundTray.alpha = lerp(SoundTray.alpha, 1.0, dt * 9.0)
        SoundTray.visible = true
    end

    local ww = love.graphics.getWidth()
    SoundTray.x = ((ww - SoundTray.width) * 0.5)

    SoundTray.offsetX = (random(-2.0, 2.0) * SoundTray._shakeMult)
    SoundTray.offsetY = (random(-2.0, 2.0) * SoundTray._shakeMult)
    
    SoundTray._shakeMult = max(SoundTray._shakeMult - (dt * 3), 0)
    SoundTray._elapsedAnimTime = SoundTray._elapsedAnimTime + dt

    if SoundTray._elapsedAnimTime >= (1.0 / curAnim.fps) then
        SoundTray.curFrame = min(SoundTray.curFrame + 1, #curAnim.frames)
        SoundTray._elapsedAnimTime = 0.0
    end
end

function SoundTray.draw()
    if not SoundTray.visible then
        return
    end
    local masterBus = AudioBus.master
    local pr, pg, pb, pa = love.graphics.getColor()

    love.graphics.setColor(1, 1, 1, 1 * SoundTray.alpha)
    love.graphics.draw(SoundTray.box, SoundTray.x + SoundTray.offsetX, SoundTray.y + SoundTray.offsetY, 0, SoundTray.scale.x, SoundTray.scale.y)

    local barX = SoundTray.x + (28 * SoundTray.scale.x) + SoundTray.offsetX
    local barY = SoundTray.y + (16 * SoundTray.scale.y) + SoundTray.offsetY
    local barCount = #SoundTray.bars

    love.graphics.setColor(1, 1, 1, 0.5 * SoundTray.alpha)
    love.graphics.draw(SoundTray.bars[barCount], barX, barY, 0, SoundTray.scale.x, SoundTray.scale.y)
    
    love.graphics.setColor(1, 1, 1, 1 * SoundTray.alpha)

    local vol = masterBus:getVolume()
    if vol > 0 and not masterBus:isMuted() then
        love.graphics.draw(SoundTray.bars[floor(vol * barCount)], barX, barY, 0, SoundTray.scale.x, SoundTray.scale.y)
    end
    love.graphics.setColor(pr, pg, pb, pa)
end

function SoundTray.input(event)
    if not event:is(InputEventKey) then
        return
    end
    local event = event --- @type chip.input.keyboard.InputEventKey
    if not event:isPressed() then
        return
    end
    local masterBus = AudioBus.master --- @type chip.audio.AudioBus

    if tblContains(SoundTray._volumeUpKeys, event:getKey()) then
        masterBus:increaseVolume(0.1, 1)
        Options.masterVolume = masterBus:getVolume()

        masterBus:setMuted(false)
        Options.muted = false

        SoundTray.show(true)
    end
    if tblContains(SoundTray._volumeDownKeys, event:getKey()) then
        masterBus:decreaseVolume(0.1, 1)
        Options.masterVolume = masterBus:getVolume()

        masterBus:setMuted(false)
        Options.muted = false

        SoundTray.show(false)
    end
    if tblContains(SoundTray._muteKeys, event:getKey()) then
        masterBus:setMuted(not masterBus:isMuted())
        Options.muted = masterBus:isMuted()
        SoundTray.show(true)
    end
end

return SoundTray