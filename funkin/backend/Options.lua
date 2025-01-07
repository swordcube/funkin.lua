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

local _default_ = "_default_"

---
--- @class funkin.backend.Options
--- 
--- A class for managing options.
---
local Options = {
    ---
    --- @protected
    --- @type chip.utils.Save
    ---
    _save = Save:new(),

    ---
    --- Controls the master volume multiplier
    --- of the whole game.
    ---
    --- @type number
    ---
    masterVolume = nil,
    _default_masterVolume = 0.3, --- @protected

    ---
    --- Controls whether or not the whole game
    --- will be muted.
    ---
    --- @type boolean
    ---
    muted = nil,
    _default_muted = false, --- @protected

    ---
    --- Controls whether or not notes vertically
    --- scroll downwards instead of upwards during gameplay.
    ---
    --- @type boolean
    ---
    downscroll = nil,
    _default_downscroll = false, --- @protected

    ---
    --- Controls the hit window for notes
    --- during gameplay.
    ---
    --- @type number
    ---
    hitWindow = nil,
    _default_hitWindow = 180, --- @protected

    ---
    --- Controls the offset of the song during
    --- gameplay, this is mainly useful for headphones
    --- or speakers with high latency.
    ---
    --- @type number
    ---
    songOffset = nil,
    _default_songOffset = 0, --- @protected

    ---
    --- Controls whether or not the game will
    --- display flashing lights in the menus or
    --- during gameplay.
    --- 
    --- If you are sensitive to this kind of
    --- context, it is recommended to leave this off!
    ---
    --- @type boolean
    ---
    flashingLights = nil,
    _default_flashingLights = true, --- @protected

    ---
    --- Controls whether or not your judgements
    --- and combo will visually stack.
    --- 
    --- Turn this off if you have performance problems,
    --- it might help!
    ---
    --- @type boolean
    ---
    comboStacking = nil,
    _default_comboStacking = true, --- @protected

    ---
    --- Controls whether or not the game will
    --- automatically pause when the window is unfocused.
    ---
    --- @type boolean
    ---
    autoPause = nil,
    _default_autoPause = true, --- @protected

    ---
    --- Controls whether or not the game will run
    --- at a maximum of 1000 TPS, saving on CPU power.
    ---
    --- @type boolean
    ---
    lowPowerMode = nil,
    _default_lowPowerMode = false, --- @protected

    ---
    --- Controls the framerate the game should
    --- try to run at. This only works if V-Sync is disabled.
    ---
    --- @type number
    ---
    targetFPS = nil,
    _default_targetFPS = 144, --- @protected

    ---
    --- Controls whether or not the game will run
    --- at an FPS matching your monitor refresh rate,
    ---
    --- @type boolean
    ---
    vsync = nil,
    _default_vsync = true, --- @protected

    ---
    --- Controls the ordering of your mods.
    ---
    --- @type table<string>
    ---
    savedMods = nil,
    _default_savedMods = {}, --- @protected

    ---
    --- Controls whether or not some of your mods are enabled.
    ---
    --- @type table<string>
    ---
    enabledMods = nil,
    _default_enabledMods = {}, --- @protected
}

function Options.init()
    local save = Options._save
    save:bind("options", "swordcube/funkin.lua")

    local doFlush = false
    for key, value in pairs(Options) do
        local skey = key:sub(#_default_ + 1)
        if type(value) ~= "function" and key:startsWith(_default_) and save.data[skey] == nil then
            doFlush = true
            save.data[skey] = rawget(Options, key)
        end
    end
    if doFlush then
        Options.save()
    end
end

function Options.save()
    local save = Options._save
    save:flush()
end

function Options.apply(option)
    local behaviors = {
        masterVolume = function(v)
            local masterBus = AudioBus.master --- @type chip.audio.AudioBus
            masterBus:setVolume(v)
        end,
        muted = function(v)
            local masterBus = AudioBus.master --- @type chip.audio.AudioBus
            masterBus:setMuted(v)
        end,
        targetFPS = function(v)
            Engine.targetFPS = v
        end,
        vsync = function(v)
            Engine.vsync = v
        end,
        lowPowerMode = function(v)
            Engine.lowPowerMode = v
        end,
        autoPause = function(v)
            Engine.autoPause = v
        end
    }
    if behaviors[option] then
        behaviors[option](Options[option])
    end
end

setmetatable(Options, {
    __index = function(t, k)
        if k:charAt(0) == "_" then
            return rawget(t, k)
        end
        return Options._save.data[k]
    end,
    __newindex = function(t, k, v)
        if k:charAt(0) == "_" then
            rawset(t, k, v)
            return
        end
        Options._save.data[k] = v
    end
})
return Options