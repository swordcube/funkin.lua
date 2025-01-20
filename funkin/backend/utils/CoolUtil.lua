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

local tblInsert = table.insert

---
--- @class funkin.backend.CoolUtil
---
local CoolUtil = {}

---
--- @param  name    string    The name of the folder containing the music, contained in `assets/music`.
--- @param  volume  number    The volume to play the music at. (defaults to `1.0`)
--- @param  loop    boolean?  Whether or not the music should loop. (defaults to `true`)
---
function CoolUtil.playMusic(name, volume, loop)
    if loop == nil then
        loop = true
    end
    BGM.play(Paths.music(name), loop)
    BGM.audioPlayer:setVolume(volume and volume or 1.0)

    local json = Json.decode(File.read(Paths.musicMeta(name)))
    Conductor.instance:reset(json.bpm)
    Conductor.instance.music = BGM.audioPlayer
    Conductor.instance.timeSignature = Conductor.timeSignatureFromString(json.timeSignature)
end

---
--- @param  volume  number?   The volume to play the music at. (defaults to `1.0`)
--- @param  loop    boolean?  Whether or not the music should loop. (defaults to `true`)
---
function CoolUtil.playMenuMusic(volume, loop)
    CoolUtil.playMusic("freakyMenu", volume, loop)
end

---
--- @param  csv  string
---
--- @return table
---
function CoolUtil.parseCSV(csv)
    local list = {}
    local splitCSV = csv:trim():replace("\r", ""):split("\n")
    for i = 1, #splitCSV do
        ---
        --- @type string
        ---
        local line = splitCSV[i]
        tblInsert(list, line:split(","))
    end
    return list
end

---
--- @param  key  string
---
function CoolUtil.formatKey(key)
    local shits = {
        [KeyCode.NONE] = "---",
        [KeyCode.LEFT] = "Left",
        [KeyCode.DOWN] = "Down",
        [KeyCode.UP] = "Up",
        [KeyCode.RIGHT] = "Right",
        [KeyCode.ENTER] = "Enter",
        [KeyCode.L_CTRL] = "LCtrl",
        [KeyCode.R_CTRL] = "RCtrl",
        [KeyCode.L_SHIFT] = "LShift",
        [KeyCode.R_SHIFT] = "RShift",
        [KeyCode.L_ALT] = "LAlt",
        [KeyCode.R_ALT] = "RAlt",
        [KeyCode.ESCAPE] = "ESC",
        [KeyCode.BACKSPACE] = "BckSpc",
        [KeyCode.SPACE] = "Space",
        [KeyCode.NUMPAD_0] = "#0",
        [KeyCode.NUMPAD_1] = "#1",
        [KeyCode.NUMPAD_2] = "#2",
        [KeyCode.NUMPAD_3] = "#3",
        [KeyCode.NUMPAD_4] = "#4",
        [KeyCode.NUMPAD_5] = "#5",
        [KeyCode.NUMPAD_6] = "#6",
        [KeyCode.NUMPAD_7] = "#7",
        [KeyCode.NUMPAD_8] = "#8",
        [KeyCode.NUMPAD_9] = "#9",
        [KeyCode.NUMPAD_PLUS] = "#+",
        [KeyCode.NUMPAD_MINUS] = "#-",
        [KeyCode.NUMPAD_PERIOD] = "#.",
        [KeyCode.NUMPAD_MULTIPLY] = "#*",
        [KeyCode.NUM_LOCK] = "NumLock",
        [KeyCode.GRAVE_ACCENT] = "`",
        [KeyCode.LBRACKET] = "[",
        [KeyCode.RBRACKET] = "]",
        [KeyCode.PRINT_SCREEN] = "PrtScrn",
        [KeyCode.QUOTE] = "'",
        [KeyCode.ZERO] = "0",
        [KeyCode.ONE] = "1",
        [KeyCode.TWO] = "2",
        [KeyCode.THREE] = "3",
        [KeyCode.FOUR] = "4",
        [KeyCode.FIVE] = "5",
        [KeyCode.SIX] = "6",
        [KeyCode.SEVEN] = "7",
        [KeyCode.EIGHT] = "8",
        [KeyCode.NINE] = "9",
        [KeyCode.COMMA] = ",",
        [KeyCode.PERIOD] = ".",
        [KeyCode.SEMICOLON] = ",",
        [KeyCode.BACKSLASH] = "\\",
        [KeyCode.SLASH] = "/",
        [KeyCode.PAGE_UP] = "PgUp",
        [KeyCode.PAGE_DOWN] = "PgDown",
        [KeyCode.TAB] = "Tab",
        [KeyCode.PLUS] = "+",
        [KeyCode.MINUS] = "-"
    }
    if key then
        return shits[key] or key:title():replace(" ", "")
    end
    return "---"
end

return CoolUtil