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
--- @class funkin.ui.options.pages.GamePage : funkin.ui.options.Page
---
local GamePage = Page:extend("GamePage", ...)

function GamePage:init()
    --- [ BOOLEAN OPTIONS ] ---
    self:addOption(BoolOption:new({
        name = "Downscroll",
        description = "Controls whether or not notes vertically\nscroll downwards instead of upwards during gameplay.",

        id = "downscroll"
    }))
    self:addOption(BoolOption:new({
        name = "Centered Notefield",
        description = "Controls whether or not your notefield\nis centered during gameplay.",

        id = "centeredNoteField"
    }))
    self:addOption(BoolOption:new({
        name = "Opponent Notes",
        description = "Controls whether or not the opponent notefield\nis visible during gameplay.",

        id = "opponentNotes"
    }))
    self:addOption(BoolOption:new({
        name = "Ghost Tapping",
        description = "Controls whether or not you can hit\nnon-existent notes during gameplay.",

        id = "ghostTapping"
    }))

    --- [ NUMBER OPTIONS ] ---
    self:addOption(NumberOption:new({
        name = "Hit Window",
        description = "Controls the hit window for notes during gameplay.",

        min = 5,
        max = 180,

        step = 5,
        decimals = 0,

        suffix = "ms",
        id = "hitWindow"
    }))
    self:addOption(NumberOption:new({
        name = "Song Offset",
        description = "Controls the offset of the song during gameplay.\nThis is mainly useful for headphones/speakers with high latency.",

        min = -5000,
        max = 5000,

        step = 5,
        decimals = 0,

        suffix = "ms",
        id = "songOffset"
    }))
    self:addOption(ChoiceOption:new({
        name = "Scoring System",
        description = "Controls the system used for calculating score during gameplay.",

        choices = {"PBot", "Week 7", "Legacy", "Judge4"},
        id = "scoringSystem"
    }))

    --- [ CONTROLS ] ---
    
    self:addOption(Separator:new(""))
    self:addOption(Separator:new("UI CONTROLS"))

    self:addOption(ControlOption:new({
        name = "LEFT",
        id = "UI_LEFT"
    }))
    self:addOption(ControlOption:new({
        name = "DOWN",
        id = "UI_DOWN"
    }))
    self:addOption(ControlOption:new({
        name = "UP",
        id = "UI_UP"
    }))
    self:addOption(ControlOption:new({
        name = "RIGHT",
        id = "UI_RIGHT"
    }))
    self:addOption(ControlOption:new({
        name = "RESET",
        id = "RESET"
    }))
    self:addOption(ControlOption:new({
        name = "ACCEPT",
        id = "ACCEPT"
    }))
    self:addOption(ControlOption:new({
        name = "BACK",
        id = "BACK"
    }))
    self:addOption(ControlOption:new({
        name = "PAUSE",
        id = "PAUSE"
    }))

    self:addOption(Separator:new(""))
    self:addOption(Separator:new("NOTE CONTROLS"))

    self:addOption(ControlOption:new({
        name = "LEFT",
        id = "NOTE_LEFT"
    }))
    self:addOption(ControlOption:new({
        name = "DOWN",
        id = "NOTE_DOWN"
    }))
    self:addOption(ControlOption:new({
        name = "UP",
        id = "NOTE_UP"
    }))
    self:addOption(ControlOption:new({
        name = "RIGHT",
        id = "NOTE_RIGHT"
    }))
end

return GamePage