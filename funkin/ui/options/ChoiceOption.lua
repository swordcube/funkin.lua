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
--- @class funkin.ui.options.ChoiceOptionData : funkin.ui.options.OptionData
---
local ChoiceOptionData = {
    name = nil, --- @type string
    description = nil, --- @type string

    choices = nil, --- @type table<string>

    id = nil, --- @type string
}

---
--- @class funkin.ui.options.ChoiceOption : funkin.ui.options.Option
---
local ChoiceOption = Option:extend("ChoiceOption", ...)

---
--- @param  data  funkin.ui.options.ChoiceOptionData
---
function ChoiceOption:constructor(data)
    ChoiceOption.super.constructor(self, data)

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
end

---
--- @return funkin.ui.options.ChoiceOptionData
---
function ChoiceOption:getData()
    return self._data
end

function ChoiceOption:select()
    self.text:setAlpha(1)
    self.valueText:setAlpha(1)

    local data = self:getData()
    local value = Options[data.id] --- @type number
    
    if value == data.choices[1] then
        self.valueText:setContents(" " .. tostring(Options[data.id]) .. " >")
    elseif value == data.choices[#data.choices] then
        self.valueText:setContents("< " .. tostring(Options[data.id]))
    else
        self.valueText:setContents("< " .. tostring(Options[data.id]) .. " >")
    end
end

function ChoiceOption:unselect()
    self.text:setAlpha(0.5)
    self.valueText:setAlpha(0.5)
    
    local data = self:getData()
    self.valueText:setContents(" " .. tostring(Options[data.id]) .. " ")
end

function ChoiceOption:input(_)
    if not self.selected then
        return
    end
    if Controls.justPressed.UI_LEFT or Controls.justPressed.UI_RIGHT then
        local data = self:getData()
        local axis = Controls.pressed.UI_LEFT and -1 or 1
        
        local index = wrap(table.indexOf(data.choices, Options[data.id]) + axis, 1, #data.choices)
        if index == -1 then
            index = 1 -- fallback to 1
        end
        local value = data.choices[index] --- @type string
        Options[data.id] = value

        if value == data.choices[1] then
            self.valueText:setContents(" " .. tostring(value) .. " >")
        elseif value == data.choices[#data.choices] then
            self.valueText:setContents("< " .. tostring(value))
        else
            self.valueText:setContents("< " .. tostring(value) .. " >")
        end
    end
end

return ChoiceOption