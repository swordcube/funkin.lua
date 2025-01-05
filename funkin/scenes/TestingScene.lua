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

---
--- @class funkin.scenes.TestingScene : chip.core.Scene
---
local TestingScene = Scene:extend("TestingScene", ...)

function TestingScene:init()
    local sprite = TiledSprite:new(200, 50) --- @type chip.graphics.TiledSprite
    -- sprite:setFrames(Paths.getSparrowAtlas("notes", "images/game/noteskins/default"))
    -- sprite.animation:addByPrefix("chud", "down hold0", 24, false)
    -- sprite.animation:play("chud")
    sprite:loadTexture(Paths.image("sustains", "images/game/noteskins/pixel"), true, 7, 6)
    sprite.animation:add("chud", {1}, 24, false)
    sprite.animation:play("chud")
    sprite:setHorizontalLength(sprite:getWidth() * 3)
    sprite:setVerticalLength(sprite:getHeight() * 8.15)
    sprite:setVerticalPadding(1.5)
    sprite:setAlpha(0.6)
    sprite.scale:set(6, 6)
    self:add(sprite)

    self.balls = sprite
end

function TestingScene:update(dt)
    if Controls.justPressed.BACK then
        AudioPlayer.playSFX(Paths.sound("cancel", "sounds/menus"))
        Engine.switchScene(require("funkin.scenes.MainMenu"):new())
    end
    self.balls:setRotationDegrees(self.balls:getRotationDegrees() + (dt * 180.0))
    TestingScene.super.update(self, dt)
end

return TestingScene