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
local lerp = math.lerp

local abs = math.abs
local round = math.round
local floor = math.floor

local min = math.min
local max = math.max

local tblInsert = table.insert
local tblContains = table.contains

---@diagnostic disable: invisible

local thread = love.thread

local HealthIcon = require("funkin.ui.HealthIcon") --- @type funkin.ui.HealthIcon
local FreeplaySongList = require("funkin.backend.utils.FreeplaySongList") --- @type funkin.backend.utils.FreeplaySongList

local MainMenu = require("funkin.scenes.MainMenu") --- @type funkin.scenes.MainMenu
local Gameplay = require("funkin.scenes.Gameplay") --- @type funkin.scenes.Gameplay

---
--- @class funkin.scenes.FreeplayMenu : chip.core.Scene
---
local FreeplayMenu = Scene:extend("FreeplayMenu", ...)

function FreeplayMenu:init()
    self:setUpdateMode("always")

    self.songList = {} --- @type table<string>
    self.songMods = {} --- @type table<string>
    self.songMetas = {} --- @type table<string, table<string, funkin.backend.song.SongMetadata>>
    
    local songShit = FreeplaySongList.get()
    for i = 1, #songShit do
        tblInsert(self.songList, songShit[i].id)
        tblInsert(self.songMods, tostring(songShit[i].mod))
        self.songMetas[songShit[i].id] = songShit[i].metas
    end
    self.curSelected = 1
    self.curDifficulty = "normal"
    self.curVariant = "default"

    self.lerpSelected = 1
    self.lerpScore = 0.0

    self.instTimer = 0.0

    ---
    --- @protected
    ---
    self._lastVisibles = {} --- @type table<integer>

    ---
    --- @protected
    ---
    self._loadedSongInsts = {} --- @type table<string, chip.audio.AudioStream>

    ---
    --- @protected
    ---
    self._loadedSongList = {} --- @type table<string>

    ---
    --- @protected
    ---
    self._playingSong = nil --- @type string

    self.bg = Sprite:new() --- @type chip.graphics.Sprite
    self.bg:loadTexture(Paths.image("desat", "images/menus"))
    self.bg:screenCenter("xy")
    self:add(self.bg)

    self.grpSongs = Group:new() --- @type chip.core.Group
    self:add(self.grpSongs)

    self.grpIcons = Group:new() --- @type chip.core.Group
    self:add(self.grpIcons)

    for i = 1, #self.songList do
        local songID = self.songList[i] --- @type string
        local songMetas = self.songMetas[songID] --- @type table<string, funkin.backend.song.SongMetadata>

        local text = AtlasText:new(0, 30 + (70 * i), "bold", "left", songMetas.default.title) --- @type funkin.ui.AtlasText
        text.targetY = i - 1
        text.isMenuItem = true
        self.grpSongs:add(text)

        local icon = HealthIcon:new(songMetas.default.icon or Constants.DEFAULT_HEALTH_ICON, false) --- @type funkin.ui.HealthIcon
        icon.tracked = text
        self.grpIcons:add(icon)
    end
    self.scoreBG = Sprite:new((Engine.gameWidth * 0.7) - 6, 0) --- @type chip.graphics.Sprite
    self.scoreBG:makeTexture(1, 66, Color.BLACK)
    self.scoreBG:setAlpha(0.6)
    self.scoreBG:setAntialiasing(false)
    self:add(self.scoreBG)

    self.scoreText = Text:new(self.scoreBG:getX() + 6, 5, 0, "PERSONAL BEST:0", 32) --- @type chip.graphics.Text
    self.scoreText:setAlignment("right")
    self.scoreText:setFont(Paths.font("vcr.ttf"))
    self:add(self.scoreText)

    self.diffText = Text:new(self.scoreText:getX(), self.scoreText:getY() + 36, 0, self.curDifficulty:upper(), 24) --- @type chip.graphics.Text
    self.diffText:setAlignment("center")
    self.diffText:setFont(Paths.font("vcr.ttf"))
    self:add(self.diffText)

    ---
    --- @protected
    ---
    self._instThread = thread.newThread([[
        local Json = require("chip.src.libs.Json")

        local audio = require("love.audio")
        local sound = require("love.sound")

        local timer = require("love.timer")
        local thread = require("love.thread")

        while true do
            local info = thread.getChannel("fi1"):pop()
            if info then
                if info.doBreak then
                    break
                end
                -- i love how this just works lmao
                local source = audio.newSource(info.instPath, "static")
                thread.getChannel("fi2"):push({
                    song = info.song,
                    source = source
                })
            end
            timer.sleep(0.01)
        end
    ]])
    self._instThread:start()

    self:changeSelection(0, true)
end

function FreeplayMenu:changeSelection(by, force)
    if by == 0 and not force then
        return
    end
    local songCount = #self.songList
    self.curSelected = wrap(self.curSelected + by, 1, songCount)

    for i = 1, songCount do
        local text = self.grpSongs:getMembers()[i] --- @type funkin.ui.AtlasText
        text.targetY = i - self.curSelected
        text:setAlpha((i == self.curSelected) and 1 or 0.6)
    end
    self:changeDifficulty(0, true)
    AudioPlayer.playSFX(Paths.sound("scroll", "sounds/menus"))
end

function FreeplayMenu:changeDifficulty(by, force)
    if by == 0 and not force then
        return
    end
    local songMetas = self.songMetas[self.songList[self.curSelected]] --- @type table<string, funkin.backend.song.SongMetadata>
    if not songMetas[self.curVariant] then
        self.curVariant = "default"
    end
    local difficulties = songMetas[self.curVariant].difficulties --- @type table<string>
    
    local prevDifficultyIndex = table.indexOf(difficulties, self.curDifficulty)
    local curDifficultyIndex = prevDifficultyIndex + by
    
    local prevVariantIndex = table.indexOf(songMetas.default.variants, self.curVariant)
    self.curDifficulty = difficulties[curDifficultyIndex]
    
    if curDifficultyIndex < 1 then
        local curVariantIndex = wrap(prevVariantIndex + by, 1, #songMetas.default.variants)
        self.curVariant = songMetas.default.variants[curVariantIndex]
        
        difficulties = songMetas[self.curVariant].difficulties
        curDifficultyIndex = #difficulties

        self.curDifficulty = difficulties[curDifficultyIndex]
        
    elseif curDifficultyIndex > #difficulties then
        curDifficultyIndex = 1
        
        local curVariantIndex = wrap(prevVariantIndex + by, 1, #songMetas.default.variants)
        self.curVariant = songMetas.default.variants[curVariantIndex]
        
        difficulties = songMetas[self.curVariant].difficulties
        self.curDifficulty = difficulties[curDifficultyIndex]
    end
    if #difficulties > 1 then
        self.diffText:setContents("< " .. self.curDifficulty:upper() .. " >")
    else
        self.diffText:setContents(self.curDifficulty:upper())
    end
    self:positionHighscore()
    self.instTimer = 0.0
end

function FreeplayMenu:update(dt)
    local songMetas = self.songMetas[self.songList[self.curSelected]] --- @type table<string, funkin.backend.song.SongMetadata>
    
    local bgColor = self.bg:getTint() --- @type chip.utils.Color
    self.bg:setTint(bgColor:interpolate(songMetas[self.curVariant]._parsedColor, dt * 2.7))

    local scoreData = Highscore.getScoreData(self.songList[self.curSelected], self.curDifficulty, self.songMods[self.curSelected]) --- @type funkin.backend.data.HighscoreData
    self.lerpScore = lerp(self.lerpScore, scoreData.score, dt * 24.0)
    
    if abs(self.lerpScore - scoreData.score) < 10 then
        self.lerpScore = scoreData.score
    end
    self.scoreText:setContents("PERSONAL BEST:" .. floor(self.lerpScore))
    self:positionHighscore()

    self.instTimer = self.instTimer + dt
    if self.instTimer > 1.0 then
        local song = self.songList[self.curSelected] .. (self.curVariant:lower() ~= "default" and ("-" .. self.curVariant:lower()) or "")
        local stream = self._loadedSongInsts[song]
        if not stream and not tblContains(self._loadedSongList, song) then
            thread.getChannel("fi1"):push({
                song = song,
                instPath = Paths.inst(song),
                doBreak = false
            })
            tblInsert(self._loadedSongList, song)
        end
        self.instTimer = -math.huge
    end
    local info = thread.getChannel("fi2"):pop()
    if info then
        local stream = AudioStream:new() --- @type chip.audio.AudioStream
        stream:setData(info.source)
        stream:reference()
        self._loadedSongInsts[info.song] = stream
    end
    local song = self.songList[self.curSelected] .. (self.curVariant:lower() ~= "default" and ("-" .. self.curVariant:lower()) or "")
    local stream = self._loadedSongInsts[song]
    if stream and self._playingSong ~= song then
        BGM.play(stream, true)
        BGM.fade(0, 1, 2)
        self._playingSong = song
    end
end

function FreeplayMenu:input(_)
    if Controls.justPressed.BACK then
        AudioPlayer.playSFX(Paths.sound("cancel", "sounds/menus"))
        Engine.switchScene(require("funkin.scenes.MainMenu"):new())
    end
    local wheel = -Input:getMouseWheelY()
    if Controls.justPressed.UI_UP or wheel < 0 then
        self:changeSelection(-1)
    end
    if Controls.justPressed.UI_DOWN or wheel > 0 then
        self:changeSelection(1)
    end
    if Controls.justPressed.UI_LEFT then
        self:changeDifficulty(-1)
    end
    if Controls.justPressed.UI_RIGHT then
        self:changeDifficulty(1)
    end
    if Controls.justPressed.BACK then
        Engine.switchScene(MainMenu:new())
    end
    if Controls.justPressed.ACCEPT then
        self:setUpdateMode("inherit")
        local mod = self.songMods[self.curSelected]
        if mod:lower() == "nil" then
            mod = nil
        end
        Engine.switchScene(Gameplay:new({
            song = self.songList[self.curSelected] .. (self.curVariant ~= "default" and ("-" .. self.curVariant) or ""),
            difficulty = self.curDifficulty,
            gameMode = "freeplay",
            currentMod = mod
        }))
    end
end

function FreeplayMenu:positionHighscore()
    self.scoreText:setX(Engine.gameWidth - self.scoreText:getWidth() - 6)
    self.scoreBG.scale.x = (Engine.gameWidth - self.scoreText:getX()) + 6
    
    self.scoreBG:setX(Engine.gameWidth - (self.scoreBG.scale.x / 2))
    self.diffText:setX(self.scoreBG:getX() - (self.diffText:getWidth() * 0.5))
end

function FreeplayMenu:free()
    for _, value in pairs(self._loadedSongInsts) do
        value:unreference()
    end
    thread.getChannel("fi1"):push({doBreak = true})
    FreeplayMenu.super.free(self)
end

return FreeplayMenu