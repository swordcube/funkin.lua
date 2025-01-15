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
local Option = require("funkin.ui.options.Option") --- @type funkin.ui.options.Option

---
--- @class funkin.ui.options.ControlOptionData : funkin.ui.options.OptionData
---
local ControlOptionData = {
    name = nil, --- @type string
    id = nil, --- @type string
}

---
--- @class funkin.ui.options.ControlOption : funkin.ui.options.Option
---
local ControlOption = Option:extend("ControlOption", ...)

---
--- @param  data  funkin.ui.options.ControlOptionData
---
function ControlOption:constructor(data)
    ControlOption.super.constructor(self, data)

    self.text = Text:new(0, 0, 0, data.name .. "\n  ", 32) --- @type chip.graphics.Text
    self.text:setFont(Paths.font("funkin.ttf"))
    self.text:setBorderSize(4)
    self.text:setBorderColor(Color.BLACK)
    self.text:setFastRendering(false)
    self:add(self.text)
    
    self.mainKeyText = Text:new(self.text:getX() + 150, 5, 0, CoolUtil.formatKey(tostring(Controls.list[data.id].keys[1])), 32) --- @type funkin.ui.AtlasText
    self.mainKeyText:setFont(Paths.font("funkin.ttf"))
    self.mainKeyText:setColor(Color.BLACK)
    self:add(self.mainKeyText)

    self.altKeyText = Text:new(self.mainKeyText:getX() + 100, 5, 0, CoolUtil.formatKey(tostring(Controls.list[data.id].keys[2])), 32) --- @type funkin.ui.AtlasText
    self.altKeyText:setFont(Paths.font("funkin.ttf"))
    self.altKeyText:setColor(Color.BLACK)
    self:add(self.altKeyText)

    ---
    --- @protected
    ---
    self._autoChangeTimer = 0.0

    self.selectedKey = 1
end

---
--- @return funkin.ui.options.ControlOptionData
---
function ControlOption:getData()
    return self._data
end

function ControlOption:select()
    self.text:setAlpha(1)

    local keys = {self.mainKeyText, self.altKeyText}
    for i = 1, #keys do
        if i == self.selectedKey then
            keys[i]:setAlpha(1)
        else
            keys[i]:setAlpha(0.45)
        end
    end
end

function ControlOption:unselect()
    self.text:setAlpha(0.6)
    self.mainKeyText:setAlpha(0.45)
    self.altKeyText:setAlpha(0.45)
end

function ControlOption:input(e)
    if not self.selected then
        return
    end
    if Controls.justPressed.UI_LEFT or Controls.justPressed.UI_RIGHT then
        local menu = require("funkin.subscenes.OptionsMenu").instance
        if menu.canInput then
            local axis = Controls.pressed.UI_LEFT and -1 or 1
            self.selectedKey = wrap(self.selectedKey + axis, 1, 2)
    
            local keys = {self.mainKeyText, self.altKeyText}
            for i = 1, #keys do
                if i == self.selectedKey then
                    keys[i]:setAlpha(1)
                else
                    keys[i]:setAlpha(0.45)
                end
            end
            AudioPlayer.playSFX(Paths.sound("scroll", "sounds/menus"))
        end
    end
    if e:is(InputEventKey) then
        local ke = e --- @type chip.input.keyboard.InputEventKey
        local menu = require("funkin.subscenes.OptionsMenu").instance
        if not menu.canInput and ke:isPressed() then
            Timer:new():start(0.001, function(_)
                local keys = {self.mainKeyText, self.altKeyText}
                keys[self.selectedKey]:setContents(CoolUtil.formatKey(tostring(ke:getKey())))
                keys[self.selectedKey]:setVisibility(true)
                
                menu.canInput = true
                Controls.list[self:getData().id].keys[self.selectedKey] = ke:getKey()
            end)
        end
    end
    if Controls.justPressed.ACCEPT then
        Timer:new():start(0.001, function(_)
            local menu = require("funkin.subscenes.OptionsMenu").instance
            menu.canInput = false
    
            local keys = {self.mainKeyText, self.altKeyText}
            keys[self.selectedKey]:setVisibility(false)
        end)
    end
end

return ControlOption