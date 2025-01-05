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

require("funkin") -- Imports a lot of default stuff

local StatsDisplay = require("funkin.backend.StatsDisplay")

---
--- @class funkin.scenes.InitScene : chip.core.Scene
---
local InitScene = Scene:extend("InitScene", ...)

function InitScene:init()
    Sprite.defaultAntialiasing = true

    local gitCmd = "git rev-parse --short HEAD"
    if love.system.getOS() == "Windows" then
        gitCmd = gitCmd .. " 2> nul"
    else
        gitCmd = gitCmd .. " 2> /dev/null"
    end
    local f = io.popen(gitCmd, "r")
    if f then
        local readHash = f:read("*l")
        if readHash then
            Constants.COMMIT_HASH = readHash:trim()
        
            if Constants.COMMIT_HASH and #Constants.COMMIT_HASH == 0 then
                -- Commit hash is blank, discard it
                Constants.COMMIT_HASH = nil
            end
            f:close()
        end
    end
    Options.init()
    Controls.init()
    
    ModLoader.init()
    Highscore.init()

    Engine.vsync = Options.vsync
    Engine.autoPause = Options.autoPause
    Engine.lowPowerMode = Options.lowPowerMode

    AudioBus.master:setVolume(Options.masterVolume)
    AudioBus.master:setMuted(Options.masterMuted)
    
    SoundTray.init()
    StatsDisplay.init()

    Conductor.instance = Conductor:new()
    Engine.plugins:add(Conductor.instance)

    Engine.preSceneSwitch:connect(function()
        Cache.clear()
    end)
    Engine.switchScene(require("funkin.scenes.TitleScreen"):new())
end

return InitScene