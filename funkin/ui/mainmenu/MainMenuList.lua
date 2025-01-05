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
--- @type funkin.ui.mainmenu.MainMenuButton
---
local MainMenuButton = require("funkin.ui.mainmenu.MainMenuButton")

---
--- @class funkin.ui.mainmenu.MainMenuList : chip.core.Group
---
local MainMenuList = Group:extend("MainMenuList", ...)

function MainMenuList:constructor()
    MainMenuList.super.constructor(self)

    ---
    --- The ID of the currently selected item.
    --- 
    --- @type integer
    ---
    self.selectedItem = 1

    ---
    --- Determines whether or not you can scroll in this menu list.
    ---
    self.enabled = true

    ---
    --- Determines whether or not this menu list is busy running an effect or something.
    ---
    self.busy = false

    ---
    --- The signal that gets emitted when the selected item has changed.
    ---
    self.onChange = Signal:new():type(MainMenuButton)

    ---
    --- The signal that gets emitted when your ACCEPT bind has been pressed on a selected item.
    ---
    self.onAcceptPress = Signal:new():type(MainMenuButton)
end

function MainMenuList:update(dt)
    MainMenuList.super.update(self, dt)

    if self.enabled and not self.busy then
        local wheel = -Input:getMouseWheelY()
        if Controls.justPressed.UI_UP or wheel < 0 then
            self:selectItem(self.selectedItem - 1)
        end
        if Controls.justPressed.UI_DOWN or wheel > 0 then
            self:selectItem(self.selectedItem + 1)
        end
        if Controls.justPressed.ACCEPT then
            ---
            --- @type funkin.ui.mainmenu.MainMenuButton
            ---
            local item = self:getMembers()[self.selectedItem]
            if item.fireImmediately then
                if item.callback then
                    item.callback()
                end
            else
                self.busy = true
                AudioPlayer.playSFX(Paths.sound("select", "sounds/menus"))
                FlickerEffect.flicker(item, 1, 0.06, true, false, function(_)
                    self.busy = false
                    if item.callback then
                        item.callback()
                    end
                end)
                self.onAcceptPress:emit(self:getMembers()[self.selectedItem])
            end
        end
    end
end

---
--- @param  name             string
--- @param  rpcName          string
--- @param  callback         function
--- @param  fireImmediately  boolean?
---
--- @return funkin.ui.mainmenu.MainMenuButton
---
function MainMenuList:addItem(name, rpcName, callback, fireImmediately)
    local item = MainMenuButton:new(name, rpcName, callback, fireImmediately)
    item.scrollFactor:set()
    self:add(item)
    return item
end

function MainMenuList:centerItems()
    local spacing = 160.0
    local top = (Engine.gameHeight - (spacing * (self:getLength() - 1))) * 0.5
    for i = 1, self:getLength() do
        ---
        --- @type funkin.ui.mainmenu.MainMenuButton
        ---
        local item = self:getMembers()[i]
        item:setPosition(Engine.gameWidth * 0.5, top + (spacing * (i - 1)))
    end
end

function MainMenuList:selectItem(index)
    index = math.wrap(index, 1, self:getLength())

    ---
    --- @type funkin.ui.mainmenu.MainMenuButton
    ---
    local oldItem = self:getMembers()[self.selectedItem]
    oldItem:playAnim("idle")

    ---
    --- @type funkin.ui.mainmenu.MainMenuButton
    ---
    local newItem = self:getMembers()[index]
    newItem:playAnim("selected")

    self.selectedItem = index
    AudioPlayer.playSFX(Paths.sound("scroll", "sounds/menus"))

    self.onChange:emit(newItem)
end

return MainMenuList