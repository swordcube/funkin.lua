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
--- @class funkin.ui.mainmenu.MainMenuButton : chip.graphics.Sprite
---
local MainMenuButton = Sprite:extend("MainMenuButton", ...)

---
--- @param  name             string    The name of this button. (`storymode`, `freeplay`, etc)
--- @param  rpcName          string    The name of this button displayed in Discord RPC. (`Story Mode`, `Freeplay`, etc)
--- @param  callback         function  The function that runs when this button is accepted.
--- @param  fireImmediately  boolean?  If set to `false`, a special effect will play before firing `callback`. Otherwise, `callback` will be fired immediately.
---
function MainMenuButton:constructor(name, rpcName, callback, fireImmediately)
    MainMenuButton.super.constructor(self)

    ---
    --- @type string
    ---
    self.name = name

    ---
    --- @type string
    ---
    self.rpcName = rpcName

    ---
    --- @type function
    ---
    self.callback = callback

    ---
    --- @type boolean
    ---
    self.fireImmediately = fireImmediately and fireImmediately or false

    self:setFrames(Paths.getSparrowAtlas("menus/main/buttons"))
    self.animation:addByPrefix("idle", string.format("%s idle", self.name), 24)
    self.animation:addByPrefix("selected", string.format("%s selected", self.name), 24)
    self:playAnim("idle")
end

function MainMenuButton:playAnim(name)
    self.animation:play(name)
    self.offset:set(self.origin.x * self:getWidth(), self.origin.y * self:getHeight())
end

return MainMenuButton