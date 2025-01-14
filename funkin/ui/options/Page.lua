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

local Option = require("funkin.ui.options.Option") --- @type funkin.ui.options.Option

---
--- @class funkin.ui.options.Page : chip.graphics.CanvasLayer
---
local Page = CanvasLayer:extend("Page", ...)

function Page:constructor()
    Page.super.constructor(self)
    self:setUpdateMode("always")

    self.curSelected = 1

    self.grpOptions = CanvasLayer:new() --- @type chip.graphics.CanvasLayer
    self:add(self.grpOptions)
    
    self:init()

    self:changeSelection(0, true)
end

function Page:init()
end

---
--- @param  option  funkin.ui.options.Option
---
function Page:addOption(option)
    local data = option:getData()
    print("Adding option: " .. data.name .. " (" .. data.id .. ")")

    if not option:is(Option) then
        Log.warn(nil, nil, nil, "You cannot add a non-option to a page!")
        return
    end
    option:setUpdateMode("always")
    option:setPosition(
        20,
        35 + (40 * self.grpOptions:getLength())
    )
    self.grpOptions:add(option)
end

function Page:changeSelection(by, force)
    if by == 0 and not force then
        return
    end
    local itemCount = self.grpOptions:getLength()
    self.curSelected = wrap(self.curSelected + by, 1, itemCount)

    local members = self.grpOptions:getMembers()
    for i = 1, itemCount do
        local option = members[i] --- @type funkin.ui.options.Option
        option.selected = i == self.curSelected
        if option.selected then
            option:select()
        else
            option:unselect()
        end
    end
    AudioPlayer.playSFX(Paths.sound("scroll", "sounds/menus"))
end

function Page:update(dt)
end

function Page:input(_)
    local wheel = -Input:getMouseWheelY()
    if Controls.justPressed.UI_UP or wheel < 0 then
        self:changeSelection(-1)
    end
    if Controls.justPressed.UI_DOWN or wheel > 0 then
        self:changeSelection(1)
    end
end

return Page