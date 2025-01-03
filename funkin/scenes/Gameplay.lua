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

local lerp = math.lerp

local UISkin = require("funkin.backend.data.UISkin") --- @type funkin.backend.data.UISkin
local Scoring = require("funkin.gameplay.scoring.Scoring") --- @type funkin.gameplay.scoring.Scoring

local Chart = require("funkin.backend.song.Chart") --- @type funkin.backend.song.Chart
local SongMetadata = require("funkin.backend.song.SongMetadata") --- @type funkin.backend.song.SongMetadata

local StrumLine = require("funkin.gameplay.StrumLine") --- @type funkin.gameplay.StrumLine
local Player = require("funkin.gameplay.Player") --- @type funkin.gameplay.Player
local NoteSpawner = require("funkin.gameplay.NoteSpawner") --- @type funkin.gameplay.NoteSpawner

local HealthIcon = require("funkin.ui.HealthIcon") --- @type funkin.ui.HealthIcon
local ComboPopups = require("funkin.gameplay.combo.ComboPopups") --- @type funkin.gameplay.combo.ComboPopups

local Stage = require("funkin.gameplay.Stage") --- @type funkin.gameplay.Stage
local Character = require("funkin.gameplay.Character") --- @type funkin.gameplay.Character

---
--- @class funkin.scenes.Gameplay : chip.core.Scene
---
local Gameplay = Scene:extend("Gameplay", ...)

---
--- @type funkin.backend.data.GameplayParams
---
Gameplay.lastParams = {
    song = "test",
    difficulty = "normal",
    gameMode = "freeplay",
    currentMod = nil
}
Gameplay.instance = nil --- @type funkin.scenes.Gameplay

function Gameplay:constructor(params)
    Gameplay.super.constructor(self)

    ---
    --- @protected
    --- @type funkin.backend.data.GameplayParams
    ---
    self._params = params or Gameplay.lastParams
    Gameplay.lastParams = self._params
end

function Gameplay:init()
    Gameplay.instance = self
    Paths.currentMod = self._params.currentMod

    -- stop any playing music
    if BGM.isPlaying() then
        BGM.stop()
    end
    -- load chart
    self.currentChart = Chart.load(self._params.song, self._params.difficulty) --- @type funkin.backend.song.chart.ChartData

    -- load inst
    BGM.audioPlayer:setVolume(1.0)
    BGM.load(Paths.inst(self._params.song))

    -- load vocal tracks
    local meta = self.currentChart.meta
    self.vocalTracks = {} --- @type table<string, chip.audio.AudioPlayer>
    
    if File.exists(Paths.voices(self._params.song, meta.characters.spectator)) then
        local spectatorVocals = AudioPlayer:new() --- @type chip.audio.AudioPlayer
        spectatorVocals:load(Paths.voices(self._params.song, meta.characters.spectator))
        self.vocalTracks[meta.characters.spectator] = spectatorVocals
        self:add(spectatorVocals)
    end
    if File.exists(Paths.voices(self._params.song, meta.characters.opponent)) then
        local opponentVocals = AudioPlayer:new() --- @type chip.audio.AudioPlayer
        opponentVocals:load(Paths.voices(self._params.song, meta.characters.opponent))
        self.vocalTracks[meta.characters.opponent] = opponentVocals
        self:add(opponentVocals)
    end
    if File.exists(Paths.voices(self._params.song, meta.characters.player)) then
        local playerVocals = AudioPlayer:new() --- @type chip.audio.AudioPlayer
        playerVocals:load(Paths.voices(self._params.song, meta.characters.player))
        self.vocalTracks[meta.characters.player] = playerVocals
        self:add(playerVocals)
    end

    -- setup stage & characters! yay!!
    local characters = self.currentChart.meta.characters
    self.spectatorCharacter = Character:new(0, 0, characters.spectator, false) --- @type funkin.gameplay.Character
    self.opponentCharacter = Character:new(0, 0, characters.opponent, false) --- @type funkin.gameplay.Character
    self.playerCharacter = Character:new(0, 0, characters.player, true) --- @type funkin.gameplay.Character

    self.stage = Stage:new(self.currentChart.meta.stage) --- @type funkin.gameplay.Stage
    self:add(self.stage)

    -- setup camera
    self.camera = Camera:new() --- @type chip.graphics.Camera
    self.camera:makeCurrent()
    self.camera:setZoom(self.stage.zoom)
    self.camera:setPosition(self.stage.startingCameraPos.x, self.stage.startingCameraPos.y)
    self:add(self.camera)

    self.curCameraTarget = 0 --- @type integer

    -- setup conductor
    self.mainConductor = Conductor.instance
    self.mainConductor.allowSongOffset = true
    self.mainConductor:setupFromChart(self.currentChart)
    self.mainConductor:setTime(self.mainConductor:getCrotchet() * -5.0)

    -- hook song ending signal shit
    BGM.audioPlayer.finished:connect(function()
        self:endSong()
    end)

    -- setup misc variables
    self.startingSong = true
    self.endingSong = false

    ---
    --- @protected
    ---
    self._currentEvent = 1 --- @type integer

    local panEvents = self.currentChart.events
    table.filter(panEvents, function(e)
        return e.time <= 20 and e.type == "Camera Pan"
    end)
    for i = 1, #panEvents do
        local event = panEvents[i]
        if type(event.params) == "number" then
            self.curCameraTarget = event.params
        else
            self.curCameraTarget = event.params.char
        end
    end

    -- scroll speed stuff
    local scrollSpeed = self.currentChart.meta.scrollSpeed
    
    -- hud layer!!!!
    self.hudLayer = CanvasLayer:new() --- @type chip.graphics.CanvasLayer
    self:add(self.hudLayer)

    -- make strumlines
    self.opponentStrumLine = StrumLine:new(Engine.gameWidth * 0.25, 50, Options.downscroll, "pixel") --- @type funkin.gameplay.StrumLine
    self.opponentStrumLine:attachNotes(table.filter(self.currentChart.notes, function(note)
        return note.lane < 4
    end))
    self.opponentStrumLine:setScrollSpeed(scrollSpeed[self._params.difficulty] or scrollSpeed.default)
    self.hudLayer:add(self.opponentStrumLine)
    
    self.playerStrumLine = StrumLine:new(Engine.gameWidth * 0.75, 50, Options.downscroll, self.currentChart.meta.uiSkin) --- @type funkin.gameplay.StrumLine
    self.playerStrumLine:attachNotes(table.filter(self.currentChart.notes, function(note)
        return note.lane > 3
    end))
    self.playerStrumLine:setScrollSpeed(scrollSpeed[self._params.difficulty] or scrollSpeed.default)
    self.hudLayer:add(self.playerStrumLine)

    -- position strumlines on downscroll
    if Options.downscroll then
        self.opponentStrumLine:setY(Engine.gameHeight - self.opponentStrumLine:getY() - self.opponentStrumLine.receptors:getHeight())
        self.playerStrumLine:setY(Engine.gameHeight - self.playerStrumLine:getY() - self.playerStrumLine.receptors:getHeight())
    end

    -- make players (these control behaviors for the 2 strumlines)
    self.opponent = Player:new(true) --- @type funkin.gameplay.Player
    self.opponent:attachStrumLines({self.opponentStrumLine})
    self:add(self.opponent)
    
    self.player = Player:new(false) --- @type funkin.gameplay.Player
    self.player:attachStrumLines({self.playerStrumLine})
    self:add(self.player)
    
    self.noteSpawner = NoteSpawner:new() --- @type funkin.gameplay.NoteSpawner
    self.noteSpawner:attachStrumLines({self.opponentStrumLine, self.playerStrumLine})
    self:add(self.noteSpawner)

    -- health bar
    self.healthBarBG = Sprite:new(0, Options.downscroll and Engine.gameHeight * 0.1 or Engine.gameHeight * 0.9) --- @type chip.graphics.Sprite
    
    local json = UISkin.get(self.currentChart.meta.uiSkin) --- @type funkin.backend.data.UISkin?
    self.healthBarBG:loadTexture(Paths.image(json.healthBar.texture, "images/" .. json.healthBar.folder))
    
    self.healthBarBG:screenCenter("x")
    self.healthBarBG.offset:set(json.healthBar.offset.x, json.healthBar.offset.y)

    self.healthBarBG.scale:set(json.healthBar.scale, json.healthBar.scale)
    self.hudLayer:add(self.healthBarBG)

    self.healthBar = ProgressBar:new() --- @type chip.graphics.ProgressBar
    self.healthBar:setColors(0xFFFF0000, 0xFF66FF33)
    self.healthBar:setFillDirection("right_to_left")

    self.healthBar:setBounds(self.player.stats.minHealth, self.player.stats.maxHealth)
    self.healthBar:setPosition(self.healthBarBG:getX() + json.healthBar.padding.x, self.healthBarBG:getY() + json.healthBar.padding.y)
    
    self.healthBar:setValue(self.player.stats.health)
    self.healthBar:resize(self.healthBarBG:getWidth() - (json.healthBar.padding.x * 2), self.healthBarBG:getHeight() - (json.healthBar.padding.y * 2))
    self.hudLayer:add(self.healthBar)

    -- icons
    self.iconP2 = HealthIcon:new(self.currentChart.meta.characters.opponent, false) --- @type funkin.ui.HealthIcon
    self.hudLayer:add(self.iconP2)

    self.iconP1 = HealthIcon:new(self.currentChart.meta.characters.player, true) --- @type funkin.ui.HealthIcon
    self.iconP1.flipX = true
    self.hudLayer:add(self.iconP1)

    -- score text
    local healthBarBG = self.healthBarBG
    self.scoreText = Text:new(healthBarBG:getX() + (healthBarBG:getWidth() - 190), healthBarBG:getY() + 30, 0, "Score: 0", 16) --- @type chip.graphics.Text
    self.scoreText:setFont(Paths.font("vcr.ttf"))
    self.scoreText:setBorderSize(1)
    self.scoreText:setBorderColor(Color.BLACK)
    self.hudLayer:add(self.scoreText)

    -- update score text and icon positions
    self:updateScoreText()
    self:updateIconPositions()

    -- combo popups
    self.comboPopups = ComboPopups:new(0, 0, self.currentChart.meta.uiSkin) --- @type funkin.gameplay.combo.ComboPopups
    self.hudLayer:add(self.comboPopups)
end

---
--- @param  event  funkin.backend.song.chart.EventData
---
function Gameplay:executeEvent(event)
    if event.type == "Camera Pan" then
        if type(event.params) == "number" then
            self.curCameraTarget = event.params
        else
            self.curCameraTarget = event.params.char
        end
    end
end

function Gameplay:update(dt)
    local mainConductor = self.mainConductor
    if self.startingSong then
        mainConductor:setTime(mainConductor:getRawTime() + (dt * 1000.0))
        if mainConductor:getRawTime() >= 0 then
            mainConductor.rawTime = 0.0
            self:startSong()
        end
    end
    if self.endingSong then
        -- if you're softlocked on song end, just press end or your back binds
        -- to instantly go to freeplay
        if Controls.justPressed.BACK then
            Engine.switchScene(require("funkin.scenes.FreeplayMenu"):new())
        end
    end
    if Engine.debugMode then
        -- if we're in debug mode, press HOME
        -- to instantly skip to the first note
        if Input.wasKeyJustPressed(KeyCode.HOME) then
            if self.startingSong then
                self:startSong()
            end
            local time = self.currentChart.notes[1].time
            self.mainConductor:setTime(time)
    
            BGM.audioPlayer:seek(time / 1000.0)
            for _, value in pairs(self.vocalTracks) do
                value:seek(time / 1000.0)
            end
        end
        -- if we're in debug mode, press END
        -- to instantly end the song
        if Input.wasKeyJustPressed(KeyCode.END) then
            if not self.endingSong then
                self:endSong()
            end
        end
    end
    local healthBar = self.healthBar
    healthBar:setBounds(self.player.stats.minHealth, self.player.stats.maxHealth)
    healthBar:setValue(lerp(healthBar:getValue(), self.player.stats.health, dt * 15.0))

    self.iconP2.health = 1.0 - healthBar:getProgress()
    self.iconP1.health = healthBar:getProgress()

    self.camera:setZoom(lerp(self.camera:getZoom(), self.stage.zoom, dt * 3.0))
    self.hudLayer:setZoom(lerp(self.hudLayer:getZoom(), 1.0, dt * 3.0))

    local chart = self.currentChart
    while self._currentEvent < #chart.events and self.mainConductor:getTime() >= chart.events[self._currentEvent].time do
        self:executeEvent(chart.events[self._currentEvent])
        self._currentEvent = self._currentEvent + 1
    end
    local focusedCharacter = self.opponentCharacter
    if self.curCameraTarget == 1 then
        focusedCharacter = self.playerCharacter
    
    elseif self.curCameraTarget == 2 then
        focusedCharacter = self.spectatorCharacter
    end
    self.camera:setPosition(
        lerp(self.camera:getX(), focusedCharacter:getCameraX(), dt * 2.4),
        lerp(self.camera:getY(), focusedCharacter:getCameraY(), dt * 2.4)
    )
    self:updateIconPositions()
    Gameplay.super.update(self, dt)
end

function Gameplay:updateIconPositions()
    local iconOffset, healthBar, iconP2, iconP1 = 26.0, self.healthBar, self.iconP2, self.iconP1
    iconP2:setPosition(
        (healthBar:getX() + (healthBar:getWidth() * (1 - healthBar:getProgress())) - ((iconP2:getWidth() - HealthIcon.HEALTH_ICON_SIZE) * 0.5)) - (HealthIcon.HEALTH_ICON_SIZE - iconOffset),
        healthBar:getY() - (HealthIcon.HEALTH_ICON_SIZE * 0.5)
    )
    iconP1:setPosition(
        (healthBar:getX() + (healthBar:getWidth() * (1 - healthBar:getProgress())) + ((iconP1:getWidth() - HealthIcon.HEALTH_ICON_SIZE) * 0.5)) - iconOffset,
        healthBar:getY() - (HealthIcon.HEALTH_ICON_SIZE * 0.5)
    )
end

function Gameplay:updateScoreText()
    if self.player.cpu then
        self.scoreText:setContents("Botplay Enabled")
        return
    end
    self.scoreText:setContents("Score: " .. math.formatMoney(self.player.stats:getScore(), false, true))
end

function Gameplay:startSong()
    local pb = self:getPlaybackRate()
    self.startingSong = false

    BGM.play(nil, false)
    BGM.audioPlayer:setPitch(pb)

    for _, value in pairs(self.vocalTracks) do
        value:setPitch(pb)
        value:play()
    end
    self.mainConductor.music = BGM.audioPlayer
end

function Gameplay:endSong()
    if self.endingSong then
        return
    end
    self.endingSong = true

    BGM.stop()
    self.mainConductor.music = nil

    local stats = self.player.stats
    local scoreData = Highscore.getScoreData(self._params.song, self._params.difficulty)
    
    local score = stats:getScore()
    local accuracy = stats:getAccuracy()

    if score > scoreData.score or accuracy > scoreData.accuracy then
        Highscore.setScoreData(self._params.song, self._params.difficulty, Paths.currentMod, {
            score = score,
            misses = stats.misses,
            maxCombo = stats.maxCombo,

            totalNotesHit = stats.totalNotesHit,
            totalJudgements = stats.judgementHits,

            accuracy = accuracy,
            rank = Scoring.getRank(accuracy),

            isValid = true
        })
        Highscore.save()
    end

    if self._params.gameMode == "story" then
        -- TODO: story mode in general lol!!
    
    elseif self._params.gameMode == "freeplay" then
        -- TODO: highscore :O
        CoolUtil.playMenuMusic()
        Engine.switchScene(require("funkin.scenes.FreeplayMenu"):new())
    
    else
        print("Unknown game mode: " .. self._params.gameMode .. ", press one of your BACK binds to go to freeplay")
    end
end

function Gameplay:beatHit(beat)
    local iconP2, iconP1 = self.iconP2, self.iconP1
    iconP2:bop()
    iconP1:bop()

    local conductor = self.mainConductor
    if beat > 0 and beat % conductor.timeSignature[1] == 0 then
        self.camera:setZoom(self.camera:getZoom() + 0.015)
        self.hudLayer:setZoom(self.hudLayer:getZoom() + 0.03)
    end
end

function Gameplay:getPlaybackRate()
    return Engine.timeScale
end

function Gameplay:setPlaybackRate(newRate)
    Engine.timeScale = newRate
    BGM.audioPlayer:setPitch(newRate)

    for _, value in pairs(self.vocalTracks) do
        value:setPitch(newRate)
    end
end

function Gameplay:free()
    self.mainConductor.allowSongOffset = false
    Gameplay.super.free(self)
end

return Gameplay