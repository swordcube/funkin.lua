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
--- @class funkin.scenes.OptionsMenu : chip.core.Scene
---
local OptionsMenu = Scene:extend("OptionsMenu", ...)

function OptionsMenu:init()
    self.curSelected = 1
    self.options = {
        {
            id = "downscroll",
            type = "bool"
        },
        {
            id = "flashingLights",
            type = "bool"
        },
        {
            id = "autoPause",
            type = "bool"
        },
        {
            id = "comboStacking",
            type = "bool"
        },
        {
            id = "targetFPS",
            type = "number",
            data = {min = 0, max = 1000, step = 4, decimals = 0}
        },
        {
            id = "vsync",
            type = "bool"
        },
        {
            id = "lowPowerMode",
            type = "bool"
        },
        {
            id = "songOffset",
            type = "number",
            data = {min = -5000, max = 5000, step = 5, decimals = 0}
        },
        {
            id = "hitWindow",
            type = "number",
            data = {min = 5, max = 180, step = 5, decimals = 0}
        },
        {
            id = "masterVolume",
            type = "number",
            data = {min = 0, max = 1, step = 0.1, decimals = 1}
        },
        {
            id = "muted",
            type = "bool",
        },
    }

    self.bg = Sprite:new() --- @type chip.graphics.Sprite
    self.bg:loadTexture(Paths.image("desat", "images/menus"))
    self.bg:screenCenter("xy")
    self.bg:setTint(0xFFea71fd)
    self:add(self.bg)

    self.grpOptions = CanvasLayer:new() --- @type chip.graphics.CanvasLayer
    self:add(self.grpOptions)

    for i = 1, #self.options do
        local option = self.options[i]

        local displayedOption = CanvasLayer:new(32, ((i - 1) * 18) + 32) --- @type chip.graphics.CanvasLayer
        self.grpOptions:add(displayedOption)

        local titleText = Text:new(0, 0, 0, option.id, 16) --- @type chip.graphics.Text
        displayedOption:add(titleText)

        local valueText = Text:new(200, 0, 0, "???", 16) --- @type chip.graphics.Text
        displayedOption:add(valueText)
    end
    self:changeSelection(0, true)

    self.disclaimerText = Text:new(2, Engine.gameHeight - 2) --- @type chip.graphics.Text
    self.disclaimerText:setFont(Paths.font("vcr.ttf"))
    self.disclaimerText:setBorderSize(1)
    self.disclaimerText:setBorderColor(Color.BLACK)

    local text = "v" .. Constants.ENGINE_VERSION
    if Constants.COMMIT_HASH then
        text = text .. " - " .. Constants.COMMIT_HASH
    end
    self.disclaimerText:setContents("THIS OPTIONS MENU IS TEMPORARY AND VERY BASIC!\nTHIS MENU WILL BE REWORKED LATER!")
    self.disclaimerText:setY(self.disclaimerText:getY() - self.disclaimerText:getHeight())
    self:add(self.disclaimerText)
end

function OptionsMenu:changeSelection(by, force)
    if by == 0 and not force then
        return
    end
    local optionCount = #self.options
    self.curSelected = wrap(self.curSelected + by, 1, optionCount)

    for i = 1, optionCount do
        local displayedOption = self.grpOptions:getMembers()[i] --- @type chip.graphics.CanvasLayer

        local titleText = displayedOption:getMembers()[1] --- @type chip.graphics.Text
        titleText:setTint((self.curSelected == i) and Color.YELLOW or Color.WHITE)

        local valueText = displayedOption:getMembers()[2] --- @type chip.graphics.Text
        valueText:setTint((self.curSelected == i) and Color.YELLOW or Color.WHITE)

        self:updateOptionDisplay(i)
    end
    AudioPlayer.playSFX(Paths.sound("scroll", "sounds/menus"))
end

function OptionsMenu:updateOptionDisplay(index)
    local option = self.options[index]
    local displayedOption = self.grpOptions:getMembers()[index] --- @type chip.graphics.CanvasLayer

    local valueText = displayedOption:getMembers()[2] --- @type chip.graphics.Text
    if option.type == "bool" then
        valueText:setContents(Options[option.id] and "ON" or "OFF")
    
    elseif option.type == "number" then
        if self.curSelected == index then
            local value = Options[option.id] --- @type number
            if value <= option.data.min then
                valueText:setContents(" " .. tostring(Options[option.id]) .. " >")
            elseif value >= option.data.max then
                valueText:setContents("< " .. tostring(Options[option.id]))
            else
                valueText:setContents("< " .. tostring(Options[option.id]) .. " >")
            end
        else
            valueText:setContents(tostring(Options[option.id]))
        end
    else
        valueText:setContents(tostring(Options[option.id]))
    end
end

function OptionsMenu:handleInputsForOption(index, option)
    local optionID = option.id --- @type string
    local optionType = option.type --- @type string

    if optionType == "bool" then
        if Controls.justPressed.ACCEPT then
            Options[optionID] = not Options[optionID]
            Options.apply(optionID)

            if optionID == "muted" then
                SoundTray.show(true)
            end
            self:updateOptionDisplay(index)
        end
    elseif optionType == "number" then
        if Controls.justPressed.UI_LEFT or Controls.justPressed.UI_RIGHT then
            local axis = Controls.pressed.UI_LEFT and -1.0 or 1.0
            local value = Options[optionID] --- @type number
            if option.data.decimals and option.data.decimals > 0 then
                value = math.truncate(value + (option.data.step * axis), option.data.decimals)
            else
                value = math.floor(value) + (math.floor(option.data.step) * axis)
            end
            Options[optionID] = math.clamp(value, option.data.min, option.data.max)
            Options.apply(optionID)

            if optionID == "masterVolume" then
                SoundTray.show(axis == 1.0)
            end
            self:updateOptionDisplay(index)
        end
    end
end

function OptionsMenu:update(dt)
    if Controls.justPressed.BACK then
        AudioPlayer.playSFX(Paths.sound("cancel", "sounds/menus"))
        Engine.switchScene(MainMenu:new())
    end
    local wheel = -Input:getMouseWheelY()
    if Controls.justPressed.UI_UP or wheel < 0 then
        self:changeSelection(-1)
    end
    if Controls.justPressed.UI_DOWN or wheel > 0 then
        self:changeSelection(1)
    end
    self:handleInputsForOption(self.curSelected, self.options[self.curSelected])
    OptionsMenu.super.update(self, dt)
end

return OptionsMenu