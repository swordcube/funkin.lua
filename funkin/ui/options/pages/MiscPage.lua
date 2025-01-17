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

local Page = require("funkin.ui.options.Page") --- @type funkin.ui.options.Page
local Separator = require("funkin.ui.options.Separator") --- @type funkin.ui.options.Separator

local BoolOption = require("funkin.ui.options.BoolOption") --- @type funkin.ui.options.BoolOption
local NumberOption = require("funkin.ui.options.NumberOption") --- @type funkin.ui.options.NumberOption
local ChoiceOption = require("funkin.ui.options.ChoiceOption") --- @type funkin.ui.options.ChoiceOption

local ControlOption = require("funkin.ui.options.ControlOption") --- @type funkin.ui.options.ControlOption

---
--- @class funkin.ui.options.pages.VisualsPage : funkin.ui.options.Page
---
local VisualsPage = Page:extend("VisualsPage", ...)

function VisualsPage:init()
    --- [ NUMBER OPTIONS ] ---
    self:addOption(NumberOption:new({
        name = "Target FPS",
        description = "Controls the framerate the game should try to run at.\nIf set to 0, there is no limit. This only works if V-Sync is disabled.",

        min = 0,
        max = 1000,

        step = 4,
        decimals = 0,

        suffix = "fps",
        id = "targetFPS"
    }))

    --- [ BOOLEAN OPTIONS ] ---
    self:addOption(BoolOption:new({
        name = "Vertical Sync",
        description = "Controls whether or not the game will run\nat an FPS matching your monitor refresh rate.",

        id = "vsync"
    }))
    self:addOption(BoolOption:new({
        name = "Parallel Updating",
        description = "Controls whether or not the game will update separately\nfrom the rendering, causing it to update more and render smoother.\n\nTurn this off if this is causing issues!",

        id = "parallelUpdating"
    }))
    self:addOption(BoolOption:new({
        name = "Freeplay Cutscenes",
        description = "Controls whether or not cutscenes will play in freeplay\ninstead of only playing in story mode.",

        id = "freeplayCutscenes"
    }))
    self:addOption(BoolOption:new({
        name = "Low Power Mode",
        description = "Controls whether or not the game will run\nat a maximum of 1000 TPS, saving on CPU power.",

        id = "lowPowerMode"
    }))
end

return VisualsPage