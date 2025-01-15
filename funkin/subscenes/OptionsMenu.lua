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

---
--- @class funkin.subscenes.OptionsMenu : chip.graphics.CanvasLayer
---
local OptionsMenu = CanvasLayer:extend("OptionsMenu", ...)

OptionsMenu.instance = nil --- @type funkin.subscenes.OptionsMenu

function OptionsMenu:constructor()
    OptionsMenu.super.constructor(self)
    OptionsMenu.instance = self
    
    Engine.paused = true
    self:setUpdateMode("always")

    self.pageList = {
        {
            name = "Game",
            page = require("funkin.ui.options.pages.GamePage")
        },
        -- {
        --     name = "Visuals",
        --     page = require("funkin.ui.options.pages.VisualsPage")
        -- },
        -- {
        --     name = "Misc",
        --     page = require("funkin.ui.options.pages.MiscPage")
        -- }
    }
    self.canInput = true

    self.bg = Sprite:new() --- @type chip.graphics.Sprite
    self.bg:makeSolid(Engine.gameWidth, Engine.gameHeight, Color.BLACK)
    self.bg:screenCenter("xy")
    self.bg:setAlpha(0.001)
    self:add(self.bg)

    self.uiLayer = CanvasLayer:new() --- @type chip.graphics.Sprite
    self.uiLayer.scale:set(0.001, 0.001)
    self:add(self.uiLayer)

    self.containerBG = Sprite:new() --- @type chip.graphics.Sprite
    self.containerBG:loadTexture(Paths.image("menuContainer", "images/menus/options"))
    self.containerBG:screenCenter("xy")
    self.containerBG:setY(self.containerBG:getY() + 20)
    self.uiLayer:add(self.containerBG)

    self.grpCategories = CanvasLayer:new(self.containerBG:getX(), self.containerBG:getY() - 20) --- @type chip.graphics.CanvasLayer
    self.uiLayer:add(self.grpCategories)

    local pageList = self.pageList
    for i = 1, #pageList do
        local page = pageList[i]

        local lastX = 0
        if self.grpCategories:getLength() > 0 then
            local lastMember = self.grpCategories:getMembers()[self.grpCategories:getLength()] --- @type chip.graphics.Text
            lastX = lastMember:getX() + (lastMember:getWidth() + 20)
        end
        local text = Text:new(lastX, 0, 0, page.name, 38) --- @type chip.graphics.Text
        text:setFont(Paths.font("funkin.ttf"))
        text:setBorderSize(4)
        text:setBorderColor(Color.BLACK)
        text:setTint(0xFF9271FD)
        self.grpCategories:add(text)
    end
    self.grpCategories:setX(self.grpCategories:getX() + ((self.containerBG:getWidth() - self.grpCategories:getWidth()) - 40))

    local padding = 4
    local uiWidth, uiHeight = 900, 540

    self.uiContainer = Viewport:new(0, 0, uiWidth - (padding * 2), uiHeight - (padding * 2)) --- @type chip.graphics.Viewport
    self.uiContainer:setPosition(
        (Engine.gameWidth - self.uiContainer:getWidth()) * 0.5,
        ((Engine.gameHeight - self.uiContainer:getHeight()) * 0.5) + 15
    )
    self.uiContainer:setClearColor(Color.TRANSPARENT)
    self.uiLayer:add(self.uiContainer)

    self.optionsThingie = Sprite:new(50, 20) --- @type chip.graphics.Sprite
    self.optionsThingie:setFrames(Paths.getSparrowAtlas("buttons", "images/menus/main"))
    self.optionsThingie.animation:addByPrefix("idle", "options selected", 24)
    self.optionsThingie.animation:play("idle")
    self.optionsThingie.scale:set(0.5, 0.5)
    self.uiLayer:add(self.optionsThingie)

    self.curPage = 1 --- @type integer
    self.pageUI = nil --- @type funkin.ui.options.Page

    local t = Tween:new() --- @type chip.tweens.Tween
    t:tweenProperty(self.bg, "alpha", 0.6, 0.4):setEase(Ease.quartInOut)

    local t = Tween:new() --- @type chip.tweens.Tween
    t:tweenProperty(self.uiLayer, "scale", Point:new(1.065, 1.065), 0.25):setEase(Ease.sineOut)
    t:tweenProperty(self.uiLayer, "scale", Point:new(1.0, 1.0), 0.25):setEase(Ease.sineInOut):setStartDelay(0.25)
    t:setUpdateCallback(function(_)
        self.uiLayer:setPosition(
            (Engine.gameWidth * (1 - self.uiLayer.scale.x)) * 0.5,
            (Engine.gameHeight * (1 - self.uiLayer.scale.y)) * 0.5
        )
    end)
    self:openPage(self.curPage)
end

function OptionsMenu:openPage(page)
    self.curPage = page
    if self.pageUI then
        self.pageUI:free()
    end
    self.pageUI = self.pageList[page].page:new()
    self.uiContainer:add(self.pageUI)
end

function OptionsMenu:input(_)
    if not self.canInput then
        return
    end
    if Controls.justPressed.BACK then
        Timer:new():start(0.001, function(_)
            Engine.paused = false

            Options.save()
            Controls.save()
            AudioPlayer.playSFX(Paths.sound("cancel", "sounds/menus"))

            local t = Tween:new() --- @type chip.tweens.Tween
            t:tweenProperty(self.bg, "alpha", 0.0, 0.4):setEase(Ease.quartInOut):setStartDelay(0.25)

            local t = Tween:new() --- @type chip.tweens.Tween
            t:tweenProperty(self.uiLayer, "scale", Point:new(1.065, 1.065), 0.25):setEase(Ease.sineOut)
            t:tweenProperty(self.uiLayer, "scale", Point:new(0.001, 0.001), 0.25):setEase(Ease.sineInOut):setStartDelay(0.25)
            t:setUpdateCallback(function(_)
                self.uiLayer:setPosition(
                    (Engine.gameWidth * (1 - self.uiLayer.scale.x)) * 0.5,
                    (Engine.gameHeight * (1 - self.uiLayer.scale.y)) * 0.5
                )
            end)
            t:setCompletionCallback(function(_)
                self:free()
            end)
        end)
    end
end

function OptionsMenu:free()
    OptionsMenu.super.free(self)
    OptionsMenu.instance = nil
end

return OptionsMenu