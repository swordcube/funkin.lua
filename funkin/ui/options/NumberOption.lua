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

local Option = require("funkin.ui.options.Option") --- @type funkin.ui.options.Option

---
--- @class funkin.ui.options.NumberOptionData : funkin.ui.options.OptionData
---
local NumberOptionData = {
    name = nil, --- @type string
    description = nil, --- @type string

    min = nil, --- @type number
    max = nil, --- @type number

    step = nil, --- @type number?
    decimals = nil, --- @type number?

    id = nil, --- @type string
}

---
--- @class funkin.ui.options.NumberOption : funkin.ui.options.Option
---
local NumberOption = Option:extend("NumberOption", ...)

---
--- @param  data  funkin.ui.options.NumberOptionData
---
function NumberOption:constructor(data)
    NumberOption.super.constructor(self, data)

    self.text = Text:new(0, 0, 0, data.name .. "\n  ", 32) --- @type chip.graphics.Text
    self.text:setFont(Paths.font("funkin.ttf"))
    self.text:setBorderSize(4)
    self.text:setBorderColor(Color.BLACK)
    self.text:setFastRendering(false)
    self:add(self.text)
    
    local value = Options[data.id] --- @type number
    self.valueText = Text:new(self.text:getX() + (self.text:getWidth() + 10), 5, 0, tostring(value), 32) --- @type funkin.ui.AtlasText
    self.valueText:setFont(Paths.font("funkin.ttf"))
    self.valueText:setColor(Color.BLACK)
    self:add(self.valueText)

    ---
    --- @protected
    ---
    self._autoChangeTimer = 0.0
end

---
--- @return funkin.ui.options.NumberOptionData
---
function NumberOption:getData()
    return self._data
end

function NumberOption:select()
    self.text:setAlpha(1)
    self.valueText:setAlpha(1)

    local data = self:getData()
    local value = Options[data.id] --- @type number
    
    if value <= data.min then
        self.valueText:setContents(" " .. tostring(Options[data.id]) .. " >")
    elseif value >= data.max then
        self.valueText:setContents("< " .. tostring(Options[data.id]))
    else
        self.valueText:setContents("< " .. tostring(Options[data.id]) .. " >")
    end
end

function NumberOption:unselect()
    self.text:setAlpha(0.6)
    self.valueText:setAlpha(0.6)
    
    local data = self:getData()
    self.valueText:setContents(" " .. tostring(Options[data.id]) .. " ")
end

function NumberOption:increment(axis)
    local data = self:getData()
    local value = Options[data.id] + (axis * data.step) --- @type number

    if data.decimals and data.decimals > 0 then
        value = math.truncate(value, data.decimals)
    end
    value = math.clamp(value, data.min, data.max)
    Options[data.id] = value

    if value <= data.min then
        self.valueText:setContents(" " .. tostring(value) .. " >")
    elseif value >= data.max then
        self.valueText:setContents("< " .. tostring(value))
    else
        self.valueText:setContents("< " .. tostring(value) .. " >")
    end
end

function NumberOption:update(dt)
    if not self.selected then
        return
    end
    if Controls.pressed.UI_LEFT or Controls.pressed.UI_RIGHT then
        local axis = Controls.pressed.UI_LEFT and -1.0 or 1.0
        self._autoChangeTimer = self._autoChangeTimer + dt
        if self._autoChangeTimer >= 0.5 then
            self._autoChangeTimer = self._autoChangeTimer - 0.05
            self:increment(axis)
        end
    else
        self._autoChangeTimer = 0.0
    end
end

function NumberOption:input(_)
    if not self.selected then
        return
    end
    if Controls.justPressed.UI_LEFT or Controls.justPressed.UI_RIGHT then
        local axis = Controls.pressed.UI_LEFT and -1.0 or 1.0
        self:increment(axis)
    end
end

return NumberOption