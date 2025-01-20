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

local min = math.min
local max = math.max
local wrap = math.wrap
local lerp = math.lerp

local OptionsMenu = require("funkin.subscenes.OptionsMenu") --- @type funkin.subscenes.OptionsMenu

local Option = require("funkin.ui.options.Option") --- @type funkin.ui.options.Option
local Separator = require("funkin.ui.options.Separator") --- @type funkin.ui.options.Separator
local ControlOption = require("funkin.ui.options.ControlOption") --- @type funkin.ui.options.ControlOption

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
    self.pageHeight = self.grpOptions:getHeight()

    self:changeSelection(0, true)
end

function Page:init()
end

---
--- @param  option  funkin.ui.options.Option
---
function Page:addOption(option)
    if not option:is(Option) then
        Log.warn(nil, nil, nil, "You cannot add a non-option to a page!")
        return
    end
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
    local members = self.grpOptions:getMembers()

    local prevItem = members[self.curSelected]
    self.curSelected = wrap(self.curSelected + by, 1, itemCount)

    while members[self.curSelected] and members[self.curSelected]:is(Separator) do
        self.curSelected = wrap(self.curSelected + by, 1, itemCount)
    end
    local curItem = members[self.curSelected]
    if prevItem:is(ControlOption) then
        local controlItem = curItem --- @type funkin.ui.options.ControlOption
        controlItem.selectedKey = prevItem.selectedKey
    end
    for i = 1, itemCount do
        local option = members[i] --- @type funkin.ui.options.Option
        option.selected = i == self.curSelected
        if option.selected then
            option:select()
        else
            option:unselect()
        end
    end
    AudioPlayer.playSFX(Paths.sound("menus/scroll"))
end

function Page:update(dt)
    if self.grpOptions:getLength() >= 12 then
        self.grpOptions:setY(lerp(self.grpOptions:getY(), min(0.0, (-40 * (self.curSelected - 12))), dt * 10.0))
    else
        self.grpOptions:setY(lerp(self.grpOptions:getY(), 0.0, dt * 25.0))
    end
end

function Page:input(_)
    local menu = OptionsMenu.instance
    if not menu.canInput then
        return
    end
    local wheel = -Input:getMouseWheelY()
    if Controls.justPressed.UI_UP or wheel < 0 then
        self:changeSelection(-1)
    end
    if Controls.justPressed.UI_DOWN or wheel > 0 then
        self:changeSelection(1)
    end
end

return Page