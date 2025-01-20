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
local tblInsert = table.insert
local tblRemove = table.remove

local Countdown = require("funkin.gameplay.Countdown") --- @type funkin.gameplay.Countdown
local OptionsMenu = require("funkin.subscenes.OptionsMenu") --- @type funkin.subscenes.OptionsMenu

---
--- @class funkin.subscenes.PauseMenu : chip.graphics.CanvasLayer
---
local PauseMenu = CanvasLayer:extend("PauseMenu", ...)

function PauseMenu:constructor()
    PauseMenu.super.constructor(self)

    self.pages = {
        DEFAULT = {
            {
                name = "Resume",
                callback = function()
                    local game = Gameplay.instance
                    game:setUpdateMode("inherit")

                    TimerManager.global:resume()
                    TweenManager.global:resume()

                    if Countdown.timer then
                        Countdown.timer:resume()
                    end
                    if not game.startingSong then
                        BGM.audioPlayer:resume()
                        for _, value in pairs(game.vocalTracks) do
                            value:seek(BGM.audioPlayer:getPlaybackTime())
                            value:resume()
                        end
                    end
                    game.paused = false
                    game:updateDiscordRPC()

                    self:free()
                end
            },
            {
                name = "Restart Song",
                callback = function()
                    self:free()
                    Engine.timeScale = 1.0
                    Engine.reloadScene()
                end
            },
            {
                name = "Change Difficulty",
                callback = function()
                    local game = Gameplay.instance
                    self.pages.CHANGE_DIFFICULTY = {
                        {
                            name = "Back",
                            callback = function()
                                self.curPage = self.pages.DEFAULT
                                self:reloadPage()
                            end
                        }
                    }
                    local newPage = self.pages.CHANGE_DIFFICULTY
                    for i = 1, #game.currentChart.meta.difficulties do
                        local difficulty = game.currentChart.meta.difficulties[i] --- @type string
                        if difficulty ~= GameplaySettings.lastParams.difficulty then
                            tblInsert(newPage, {
                                name = difficulty,
                                callback = function()
                                    GameplaySettings.lastParams.difficulty = difficulty

                                    self:free()
                                    Engine.reloadScene()
                                end
                            })
                        end
                    end
                    self.curPage = newPage
                    self:reloadPage()
                end
            },
            {
                name = "Change Options",
                callback = function()
                    self._paused = true
                    Timer:new():start(0.001, function(_)
                        self:add(OptionsMenu:new())
                    end)
                end
            },
            {
                name = "Exit to Menu",
                callback = function()
                    local game = Gameplay.instance
                    if game._params.gameMode == "story" then
                        -- TODO: story mode in general lol!!
                    
                    elseif game._params.gameMode == "freeplay" then
                        -- TODO: highscore :O
                        CoolUtil.playMenuMusic()

                        self:free()
                        Engine.timeScale = 1.0

                        Engine.switchScene(require("funkin.scenes.FreeplayMenu"):new())
                    end
                end
            }
        },
        CHANGE_DIFFICULTY = {}
    }
    local game = Gameplay.instance
    if #game.currentChart.meta.difficulties < 2 then
        tblRemove(self.pages.DEFAULT, 3)
    end
    self.curPage = self.pages.DEFAULT
    self.curSelected = 1

    ---
    --- @protected
    ---
    self._canInput = false

    ---
    --- @protected
    ---
    self._paused = false

    ---
    --- @protected
    ---
    self._prevTimeScale = Engine.timeScale
    Engine.timeScale = 1.0

    self:setUpdateMode("always")
    Gameplay.instance:setUpdateMode("disabled")

    TimerManager.global:pause()
    TweenManager.global:pause()

    self.pauseMusic = AudioPlayer:new() --- @type chip.audio.AudioPlayer
    self:add(self.pauseMusic)

    self.pauseMusic:load(Paths.music("breakfast"))
    self.pauseMusic:setVolume(0.0)
    self.pauseMusic:setLooping(true)
    self.pauseMusic:play()

    self.bg = Sprite:new() --- @type chip.graphics.Sprite
    self.bg:makeSolid(Engine.gameWidth, Engine.gameHeight, Color.BLACK)
    self.bg:screenCenter("xy")
    self.bg:setAlpha(0.001)
    self:add(self.bg)

    self.grpOptions = CanvasLayer:new() --- @type chip.graphics.CanvasLayer
    self:add(self.grpOptions)

    self.songInfo = Text:new(20, 15, 0, game.currentChart.meta.title) --- @type chip.graphics.Text
    self.difficultyInfo = Text:new(20, 15, 0, GameplaySettings.lastParams.difficulty:upper()) --- @type chip.graphics.Text
    self.deathInfo = Text:new(20, 15, 0, "Blue balled: " .. "N/A") --- @type chip.graphics.Text

    local labels = {self.songInfo, self.difficultyInfo, self.deathInfo}
    for i = 1, #labels do
        local label = labels[i] --- @type chip.graphics.Text
        label:setFont(Paths.font("vcr.ttf"))
        label:setAlignment("right")
        label:setSize(32)
        label:setAlpha(0.001)
        label:setColor(Color.WHITE)
        label:setPosition(
            Engine.gameWidth - (label:getWidth() + 20),
            15 + ((i - 1) * 32)
        )
        self:add(label)

        local t = Tween:new() --- @type chip.tweens.Tween
        t:tweenProperty(label, "alpha", 1, 0.4):setEase(Ease.quartInOut):setStartDelay(0.3 * i)
        t:tweenProperty(label, "y", label:getY() + 5, 0.4):setEase(Ease.quartInOut):setStartDelay(0.3 * i)
    end
    self:reloadPage()

    local t = Tween:new() --- @type chip.tweens.Tween
    t:tweenProperty(self.bg, "alpha", 0.6, 0.4):setEase(Ease.quartInOut)
    t:tweenProperty(self.pauseMusic, "volume", 0.5, 25)

    self.memberRemoved:connect(function(m)
        if m:is(OptionsMenu) then
            self._paused = false
        end
    end)

    Discord.changePresence({
        details = "(PAUSED) " .. game.currentChart.meta.title .. " (" .. game._params.difficulty:upper() .. ")",
        state = game.player.stats:getScore() .. " (" .. math.truncate(game.player.stats:getAccuracy() * 100, 2) .. "%) - " .. game.player.stats.misses .. " miss" .. (game.player.stats.misses == 1 and "" or "es"),
    })
end

function PauseMenu:update(_)
    self._canInput = true
end

function PauseMenu:input(_)
    if not self._canInput or self._paused then
        return
    end
    local wheel = -Input:getMouseWheelY()
    if Controls.justPressed.UI_UP or wheel < 0 then
        self:changeSelection(-1)
    end
    if Controls.justPressed.UI_DOWN or wheel > 0 then
        self:changeSelection(1)
    end
    if Controls.justPressed.ACCEPT then
        self.curPage[self.curSelected].callback()
    end
end

function PauseMenu:reloadPage()
    while self.grpOptions:getLength() > 0 do
        local item = self.grpOptions:getMembers()[1] --- @type funkin.ui.AtlasText
        item:free()
    end
    local curPage = self.curPage
    for i = 1, #curPage do
        local item = curPage[i]
        
        local text = AtlasText:new(0, 30 + (70 * i), "bold", "left", item.name) --- @type funkin.ui.AtlasText
        text.targetY = i - 1
        text.isMenuItem = true
        self.grpOptions:add(text)
    end
    self.curSelected = 1
    self:changeSelection(0, true)
end

function PauseMenu:changeSelection(by, force)
    if by == 0 and not force then
        return
    end
    local itemCount = #self.curPage
    self.curSelected = wrap(self.curSelected + by, 1, itemCount)

    for i = 1, itemCount do
        local text = self.grpOptions:getMembers()[i] --- @type funkin.ui.AtlasText
        text.targetY = i - self.curSelected
        text:setAlpha((i == self.curSelected) and 1 or 0.6)
    end
    AudioPlayer.playSFX(Paths.sound("menus/scroll"))
end

function PauseMenu:free()
    Engine.timeScale = self._prevTimeScale
    PauseMenu.super.free(self)
end

return PauseMenu