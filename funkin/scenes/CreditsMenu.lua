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

local wrap = math.wrap
local lerp = math.lerp

local round = math.round
local floor = math.floor

local min = math.min
local max = math.max

---@diagnostic disable: invisible

local MainMenu = require("funkin.scenes.MainMenu") --- @type funkin.scenes.MainMenu

---
--- @class funkin.scenes.CreditsMenu : chip.core.Scene
---
local CreditsMenu = Scene:extend("CreditsMenu", ...)

function CreditsMenu:init()
    self.bg = Sprite:new() --- @type chip.graphics.Sprite
    self.bg:loadTexture(Paths.image("desat", "images/menus"))
    self.bg:screenCenter("xy")
    self:add(self.bg)

    self.footer = Sprite:new() --- @type chip.graphics.Sprite
    self.footer:makeSolid(Engine.gameWidth, 50, Color.BLACK)
    self.footer:setY(Engine.gameHeight - (self.footer:getHeight() * 0.5))
    self.footer:screenCenter("x")
    self.footer:setAlpha(0.6)
    self:add(self.footer)

    self.curSelected = 1
    self:changeSelection(0, true)
end

function CreditsMenu:changeSelection(by, force)
    if by == 0 and not force then
        return
    end
    AudioPlayer.playSFX(Paths.sound("scroll", "sounds/menus"))
end

function CreditsMenu:update(dt)
    if Controls.justPressed.BACK then
        AudioPlayer.playSFX(Paths.sound("cancel", "sounds/menus"))
        Engine.switchScene(MainMenu:new())
    end
    CreditsMenu.super.update(self, dt)
end

return CreditsMenu