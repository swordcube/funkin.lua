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
local Checkbox = require("funkin.ui.Checkbox") --- @type funkin.ui.Checkbox

---
--- @class funkin.ui.options.BoolOptionData : funkin.ui.options.OptionData
---
local BoolOptionData = {
    name = nil, --- @type string
    description = nil, --- @type string

    id = nil, --- @type string
}

---
--- @class funkin.ui.options.BoolOption : funkin.ui.options.Option
---
local BoolOption = Option:extend("BoolOption", ...)

---
--- @param  data  funkin.ui.options.BoolOptionData
---
function BoolOption:constructor(data)
    BoolOption.super.constructor(self, data)

    self.text = Text:new(0, 0, 0, data.name .. "\n  ", 32) --- @type chip.graphics.Text
    self.text:setFont(Paths.font("funkin.ttf"))
    self.text:setBorderSize(4)
    self.text:setBorderColor(Color.BLACK)
    self.text:setFastRendering(false)
    self:add(self.text)

    self.checkbox = Checkbox:new(self.text:getWidth() - 20, -30) --- @type funkin.ui.Checkbox
    self.checkbox.scale:set(0.35, 0.35)
    self:add(self.checkbox)

    local value = Options[data.id] --- @type boolean
    if value then
        self.checkbox:select()
    else
        self.checkbox:unselect()
    end
    self.checkbox.animation:finish()
end

---
--- @return funkin.ui.options.BoolOptionData
---
function BoolOption:getData()
    return self._data
end

function BoolOption:select()
    self.checkbox:setAlpha(1)
    self.text:setAlpha(1)
end

function BoolOption:unselect()
    self.checkbox:setAlpha(0.5)
    self.text:setAlpha(0.5)
end

function BoolOption:input(_)
    if not self.selected then
        return
    end
    if Controls.justPressed.ACCEPT or (Input.wasMouseJustPressed("left") and (MouseCursor.overlaps(self.text) or MouseCursor.overlaps(self.checkbox))) then
        local data = self:getData()
        Options[data.id] = not Options[data.id]

        if Options[data.id] then
            self.checkbox:select()
        else
            self.checkbox:unselect()
        end
        Options.apply(data.id)
    end
end

return BoolOption