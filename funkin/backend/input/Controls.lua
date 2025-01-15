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
--- @type funkin.backend.input.InputAction
---
local InputAction = require("funkin.backend.input.InputAction")

---
--- @class funkin.input.Controls
---
local Controls = {}

function Controls.init()
    ---
    --- @type chip.utils.Save
    ---
    Controls._save = Save:new()
    Controls._save:bind("controls", "swordcube/funkin.lua")

    Controls.list = {
        -- Gameplay Bindings
        NOTE_LEFT  = InputAction:new("note_left",  {KeyCode.A, KeyCode.LEFT}), --- @type funkin.backend.input.InputAction
        NOTE_DOWN  = InputAction:new("note_down",  {KeyCode.S, KeyCode.DOWN}), --- @type funkin.backend.input.InputAction
        NOTE_UP    = InputAction:new("note_up",    {KeyCode.W, KeyCode.UP}), --- @type funkin.backend.input.InputAction
        NOTE_RIGHT = InputAction:new("note_right", {KeyCode.D, KeyCode.RIGHT}), --- @type funkin.backend.input.InputAction

        -- UI Bindings
        UI_LEFT  = InputAction:new("ui_left",  {KeyCode.A, KeyCode.LEFT}), --- @type funkin.backend.input.InputAction
        UI_DOWN  = InputAction:new("ui_down",  {KeyCode.S, KeyCode.DOWN}), --- @type funkin.backend.input.InputAction
        UI_UP    = InputAction:new("ui_up",    {KeyCode.W, KeyCode.UP}), --- @type funkin.backend.input.InputAction
        UI_RIGHT = InputAction:new("ui_right", {KeyCode.D, KeyCode.RIGHT}), --- @type funkin.backend.input.InputAction

        RESET    = InputAction:new("reset", {KeyCode.R, KeyCode.NONE}), --- @type funkin.backend.input.InputAction
        ACCEPT   = InputAction:new("accept", {KeyCode.ENTER, KeyCode.SPACE}), --- @type funkin.backend.input.InputAction
        BACK     = InputAction:new("back",   {KeyCode.ESCAPE, KeyCode.BACKSPACE}), --- @type funkin.backend.input.InputAction
        PAUSE    = InputAction:new("pause", {KeyCode.ENTER, KeyCode.ESCAPE}), --- @type funkin.backend.input.InputAction

        -- Window Bindings
        SCREENSHOT = InputAction:new("screenshot", {KeyCode.F3, KeyCode.NONE}), --- @type funkin.backend.input.InputAction
        FULLSCREEN = InputAction:new("fullscreen", {KeyCode.F11, KeyCode.NONE}), --- @type funkin.backend.input.InputAction

        -- Volume Bindings
        VOLUME_UP = InputAction:new("volume_up", {KeyCode.EQUALS, KeyCode.NUMPAD_PLUS}), --- @type funkin.backend.input.InputAction
        VOLUME_DOWN = InputAction:new("volume_down", {KeyCode.MINUS, KeyCode.NUMPAD_MINUS}), --- @type funkin.backend.input.InputAction
        VOLUME_MUTE = InputAction:new("volume_mute", {KeyCode.ZERO, KeyCode.NUMPAD_0}), --- @type funkin.backend.input.InputAction

        -- Debug Bindings
        EDITORS = InputAction:new("editors", {KeyCode.EIGHT, KeyCode.NUMPAD_8}), --- @type funkin.backend.input.InputAction
        CHARTER = InputAction:new("charter", {KeyCode.SEVEN, KeyCode.NUMPAD_7}), --- @type funkin.backend.input.InputAction
        SWITCH_MOD = InputAction:new("switch_mod", {KeyCode.TAB, KeyCode.NONE}), --- @type funkin.backend.input.InputAction
    }
    ---
    --- Helpful dot syntax for checking if an action was just pressed.
    ---
    Controls.justPressed = {
        NOTE_LEFT  = nil, --- @type funkin.backend.input.InputAction
        NOTE_DOWN  = nil, --- @type funkin.backend.input.InputAction
        NOTE_UP    = nil, --- @type funkin.backend.input.InputAction
        NOTE_RIGHT = nil, --- @type funkin.backend.input.InputAction
        UI_LEFT  = nil, --- @type funkin.backend.input.InputAction
        UI_DOWN  = nil, --- @type funkin.backend.input.InputAction
        UI_UP    = nil, --- @type funkin.backend.input.InputAction
        UI_RIGHT = nil, --- @type funkin.backend.input.InputAction
        RESET    = nil, --- @type funkin.backend.input.InputAction
        ACCEPT   = nil, --- @type funkin.backend.input.InputAction
        BACK     = nil, --- @type funkin.backend.input.InputAction
        PAUSE    = nil, --- @type funkin.backend.input.InputAction
        SCREENSHOT = nil, --- @type funkin.backend.input.InputAction
        FULLSCREEN = nil, --- @type funkin.backend.input.InputAction
        VOLUME_UP = nil, --- @type funkin.backend.input.InputAction
        VOLUME_DOWN = nil, --- @type funkin.backend.input.InputAction
        VOLUME_MUTE = nil, --- @type funkin.backend.input.InputAction
        EDITORS = nil, --- @type funkin.backend.input.InputAction
        CHARTER = nil, --- @type funkin.backend.input.InputAction
        SWITCH_MOD = nil, --- @type funkin.backend.input.InputAction
    }

    ---
    --- Helpful dot syntax for checking if an action is pressed.
    ---
    Controls.pressed = {
        NOTE_LEFT  = nil, --- @type funkin.backend.input.InputAction
        NOTE_DOWN  = nil, --- @type funkin.backend.input.InputAction
        NOTE_UP    = nil, --- @type funkin.backend.input.InputAction
        NOTE_RIGHT = nil, --- @type funkin.backend.input.InputAction
        UI_LEFT  = nil, --- @type funkin.backend.input.InputAction
        UI_DOWN  = nil, --- @type funkin.backend.input.InputAction
        UI_UP    = nil, --- @type funkin.backend.input.InputAction
        UI_RIGHT = nil, --- @type funkin.backend.input.InputAction
        RESET    = nil, --- @type funkin.backend.input.InputAction
        ACCEPT   = nil, --- @type funkin.backend.input.InputAction
        BACK     = nil, --- @type funkin.backend.input.InputAction
        PAUSE    = nil, --- @type funkin.backend.input.InputAction
        SCREENSHOT = nil, --- @type funkin.backend.input.InputAction
        FULLSCREEN = nil, --- @type funkin.backend.input.InputAction
        VOLUME_UP = nil, --- @type funkin.backend.input.InputAction
        VOLUME_DOWN = nil, --- @type funkin.backend.input.InputAction
        VOLUME_MUTE = nil, --- @type funkin.backend.input.InputAction
        EDITORS = nil, --- @type funkin.backend.input.InputAction
        CHARTER = nil, --- @type funkin.backend.input.InputAction
        SWITCH_MOD = nil, --- @type funkin.backend.input.InputAction
    }

    ---
    --- Helpful dot syntax for checking if an action was just released.
    ---
    Controls.justReleased = {
        NOTE_LEFT  = nil, --- @type funkin.backend.input.InputAction
        NOTE_DOWN  = nil, --- @type funkin.backend.input.InputAction
        NOTE_UP    = nil, --- @type funkin.backend.input.InputAction
        NOTE_RIGHT = nil, --- @type funkin.backend.input.InputAction
        UI_LEFT  = nil, --- @type funkin.backend.input.InputAction
        UI_DOWN  = nil, --- @type funkin.backend.input.InputAction
        UI_UP    = nil, --- @type funkin.backend.input.InputAction
        UI_RIGHT = nil, --- @type funkin.backend.input.InputAction
        RESET    = nil, --- @type funkin.backend.input.InputAction
        ACCEPT   = nil, --- @type funkin.backend.input.InputAction
        BACK     = nil, --- @type funkin.backend.input.InputAction
        PAUSE    = nil, --- @type funkin.backend.input.InputAction
        SCREENSHOT = nil, --- @type funkin.backend.input.InputAction
        FULLSCREEN = nil, --- @type funkin.backend.input.InputAction
        VOLUME_UP = nil, --- @type funkin.backend.input.InputAction
        VOLUME_DOWN = nil, --- @type funkin.backend.input.InputAction
        VOLUME_MUTE = nil, --- @type funkin.backend.input.InputAction
        EDITORS = nil, --- @type funkin.backend.input.InputAction
        CHARTER = nil, --- @type funkin.backend.input.InputAction
        SWITCH_MOD = nil, --- @type funkin.backend.input.InputAction
    }

    ---
    --- Helpful dot syntax for checking if an action is released.
    ---
    Controls.released = {
        NOTE_LEFT  = nil, --- @type funkin.backend.input.InputAction
        NOTE_DOWN  = nil, --- @type funkin.backend.input.InputAction
        NOTE_UP    = nil, --- @type funkin.backend.input.InputAction
        NOTE_RIGHT = nil, --- @type funkin.backend.input.InputAction
        UI_LEFT  = nil, --- @type funkin.backend.input.InputAction
        UI_DOWN  = nil, --- @type funkin.backend.input.InputAction
        UI_UP    = nil, --- @type funkin.backend.input.InputAction
        UI_RIGHT = nil, --- @type funkin.backend.input.InputAction
        RESET    = nil, --- @type funkin.backend.input.InputAction
        ACCEPT   = nil, --- @type funkin.backend.input.InputAction
        BACK     = nil, --- @type funkin.backend.input.InputAction
        PAUSE    = nil, --- @type funkin.backend.input.InputAction
        SCREENSHOT = nil, --- @type funkin.backend.input.InputAction
        FULLSCREEN = nil, --- @type funkin.backend.input.InputAction
        VOLUME_UP = nil, --- @type funkin.backend.input.InputAction
        VOLUME_DOWN = nil, --- @type funkin.backend.input.InputAction
        VOLUME_MUTE = nil, --- @type funkin.backend.input.InputAction
        EDITORS = nil, --- @type funkin.backend.input.InputAction
        CHARTER = nil, --- @type funkin.backend.input.InputAction
        SWITCH_MOD = nil, --- @type funkin.backend.input.InputAction
    }

    setmetatable(Controls.justPressed, {
        __index = function(_, control)
            ---
            --- @type funkin.backend.input.InputAction
            ---
            local action = Controls.list[control]
            return action:check(InputState.JUST_PRESSED)
        end
    })
    setmetatable(Controls.pressed, {
        __index = function(_, control)
            ---
            --- @type funkin.backend.input.InputAction
            ---
            local action = Controls.list[control]
            return action:check(InputState.PRESSED)
        end
    })
    setmetatable(Controls.justReleased, {
        __index = function(_, control)
            ---
            --- @type funkin.backend.input.InputAction
            ---
            local action = Controls.list[control]
            return action:check(InputState.JUST_RELEASED)
        end
    })
    setmetatable(Controls.released, {
        __index = function(_, control)
            ---
            --- @type funkin.backend.input.InputAction
            ---
            local action = Controls.list[control]
            return action:check(InputState.RELEASED)
        end
    })
end

function Controls.save()
    local save = Controls._save
    save:flush()
end

return Controls