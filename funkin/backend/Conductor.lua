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

local abs = math.abs
local floor = math.floor
local tblInsert = table.insert

---
--- @class funkin.backend.Conductor : chip.core.Actor
---
local Conductor = Actor:extend("Conductor", ...)

---
--- The main global instance of the Conductor.
---
--- @type funkin.backend.Conductor
---
Conductor.instance = nil

Conductor.judgeScales = {
    J1 = 1.5,
    J2 = 1.33,
    J3 = 1.16,
    J4 = 1.0,
    J5 = 0.84,
    J6 = 0.66,
    J7 = 0.5,
    J8 = 0.33,
    JUSTICE = 0.2,
}

function Conductor.timeSignatureFromString(str)
    local split = string.split(str, "/")
    return {tonumber(split[1]), tonumber(split[2])}
end

function Conductor:constructor()
    Conductor.super.constructor(self)

    self:setVisibility(false)

    ---
    --- @type chip.utils.Signal
    ---
    self.stepHit = Signal:new():type("number", "void")

    ---
    --- @type chip.utils.Signal
    ---
    self.beatHit = Signal:new():type("number", "void")

    ---
    --- @type chip.utils.Signal
    ---
    self.measureHit = Signal:new():type("number", "void")

    ---
    --- @type boolean
    ---
    self.hasMetronome = false

    ---
    --- @type chip.audio.AudioPlayer?
    ---
    self.music = nil

    ---
    --- @type number
    ---
    self.bpm = 100.0

    ---
    --- @type table
    ---
    self.bpmChanges = {
        {
            step = 0,
            time = 0.0,
            bpm = 100.0
        }
    }

    ---
    --- @type table<number>
    ---
    self.timeSignature = {4, 4}
    -- ^^ - 1st num is beats per measure, 2nd num is steps per beat

    ---
    --- @type number
    ---
    self.safeZoneOffset = Options.hitWindow

    ---
    --- @type boolean
    ---
    self.allowSongOffset = false

    ---
    --- @type number
    ---
    self.rawTime = 0.0

    ---
    --- @type number
    ---
    self.rawMusicTime = 0.0

    ---
    --- @type integer
    ---
    self.lastStep = 0

    ---
    --- @type integer
    ---
    self.lastBeat = 0

    ---
    --- @type integer
    ---
    self.lastMeasure = 0

    ---
    --- @type number
    ---
    self.stepf = 0.0

    ---
    --- @type integer
    ---
    self.step = 0

    ---
    --- @type number
    ---
    self.beatf = 0.0

    ---
    --- @type integer
    ---
    self.beat = 0

    ---
    --- @type number
    ---
    self.measuref = 0.0

    ---
    --- @type integer
    ---
    self.measure = 0

    ---
    --- @protected
    --- @type table
    ---
    self._lastBPMChange = self.bpmChanges[1]
end

function Conductor:reset(bpm)
    self:setTime(0.0)

    self.measuref = 0.0
    self.measure = 0

    self.beatf = 0.0
    self.beat = 0

    self.stepf = 0.0
    self.step = 0

    self.timeSignature = {4, 4}
    self.bpmChanges = {
        {
            step = 0,
            time = 0.0,
            bpm = bpm
        }
    }
    self.bpm = bpm
end

function Conductor:setupFromChart(chart)
    self:reset()
    self.timeSignature = Conductor.timeSignatureFromString(chart.meta.timeSignature)

    self.bpm = chart.meta.bpm
    self:setupBPMChanges(chart)
end

function Conductor:setupBPMChanges(chart)
    self.bpmChanges = {
        {
            time = 0.0,
            step = 0,
            bpm = chart.meta.bpm
        }
    }
    if not chart.events or #chart.events == 0 then
        return
    end
    local timeSig = Conductor.timeSignatureFromString(chart.meta.timeSignature)

    local curBPM = 0.0
    local time = 0.0
    local steps = 0.0

    for i = 1, #chart.events do
        local event = chart.events[i]
        if event.type == "BPM Change" and event.params and type(event.params.bpm) == "number" then
            local eventBPM = event.params.bpm
            if eventBPM ~= curBPM then
                steps = steps + ((event.time - time) / (((60 / curBPM) / timeSig[2]) * 1000))
                
                time = event.time
                curBPM = eventBPM

                tblInsert(self.bpmChanges, {
                    time = time,
                    step = steps,
                    bpm = curBPM
                })
                lastStep = event.step
            end
        end
    end
end

function Conductor:stepToTime(step)
    local lastChange = self.bpmChanges[1]

    for i = 2, #self.bpmChanges do
        local change = self.bpmChanges[i]

        if self.rawTime >= change.time then
            lastChange = change
        end
    end

    return lastChange.time + ((step - lastChange.time) * (((60 / lastChange.bpm) * self.timeSignature[2]) * 1000.0))
end

function Conductor:beatToTime(beat)
    return self:stepToTime(beat * self.timeSignature[2])
end

function Conductor:measureToTime(measure)
    return self:beatToTime(measure * self.timeSignature[1])
end

function Conductor:timeToStep(time)
    local lastChange = self.bpmChanges[1]

    for i = 2, #self.bpmChanges do
        local change = self.bpmChanges[i]

        if time >= change.time then
            lastChange = change
        end
    end

    return lastChange.step + ((time - lastChange.time) / (((60 / lastChange.bpm) * self.timeSignature[2]) * 1000.0))
end

function Conductor:timeToBeat(time)
    return self:timeToStep(time) / self.timeSignature[2]
end

function Conductor:timeToMeasure(time)
    return self:timeToBeat(time) / self.timeSignature[1]
end

function Conductor:update(dt)
    if self.music and self.music:isPlaying() then
        local musicTime = floor(self.music:getPlaybackTime() * 1000.0)
        if musicTime ~= self.rawMusicTime then
            self.rawTime = musicTime
        else
            self.rawTime = self.rawTime + (dt * 1000.0)
        end
        self.rawMusicTime = musicTime
    end
    local time = self:getTime()
    self._lastBPMChange = self.bpmChanges[1]
    for i = 2, #self.bpmChanges do
        local change = self.bpmChanges[i]

        if time >= change.time then
            self._lastBPMChange = change
        end
    end
    local lastBPMChange = self._lastBPMChange
    if lastBPMChange.bpm > 0 and self.bpm ~= lastBPMChange.bpm then
        self.bpm = lastBPMChange.bpm
    end
    local runStep = self:_updateStep(((time - self._lastBPMChange.time) / self:getStepCrotchet()) + self._lastBPMChange.step)
    if runStep then
        if abs(self.lastStep - self.step) > 1 then
            for i = self.lastStep, self.step do
                self.stepHit:emit(i)
            end
        else
            self.stepHit:emit(self.step)
        end
    end
    local runBeat = self:_updateBeat(self.stepf / self.timeSignature[2])
    if runStep and runBeat then
        if abs(self.lastBeat - self.beat) > 1 then
            for i = self.lastBeat, self.beat do
                self.beatHit:emit(i)
            end
        else
            self.beatHit:emit(self.beat)
        end
        if self.hasMetronome then
            local audio = AudioPlayer.playSFX(Paths.sound("metronome"))
            local measure = self.beat % self.timeSignature[1]
            audio:setPitch((measure == 0) and 1.5 or 1.12)
        end
    end
    local runMeasure = self:_updateMeasure(self.beatf / self.timeSignature[1])
    if runStep and runMeasure then
        if abs(self.lastMeasure - self.measure) > 1 then
            for i = self.lastMeasure, self.measure do
                self.measureHit:emit(i)
            end
        else
            self.measureHit:emit(self.measure)
        end
    end
    local scene = Engine.currentScene
    if not scene or not scene:isActive() then
        return
    end
    if runStep then
        if abs(self.lastStep - self.step) > 1 then
            for i = self.lastStep, self.step do
                Conductor._callOnActor(Engine.currentScene, "stepHit", i)
            end
        else
            Conductor._callOnActor(Engine.currentScene, "stepHit", self.step)
        end
    end
    if runStep and runBeat then
        if abs(self.lastBeat - self.beat) > 1 then
            for i = self.lastBeat, self.beat do
                Conductor._callOnActor(Engine.currentScene, "beatHit", i)
            end
        else
            Conductor._callOnActor(Engine.currentScene, "beatHit", self.beat)
        end
    end
    if runStep and runMeasure then
        if abs(self.lastMeasure - self.measure) > 1 then
            for i = self.lastMeasure, self.measure do
                Conductor._callOnActor(Engine.currentScene, "measureHit", i)
            end
        else
            Conductor._callOnActor(Engine.currentScene, "measureHit", self.measure)
        end
    end
end

function Conductor:getRawTime()
    return self.rawTime
end

function Conductor:getTime()
    return self.rawTime - (self.allowSongOffset and Options.songOffset or 0.0)
end

function Conductor:setTime(val)
    self.rawTime = val
end

function Conductor:getCrotchet()
    return (60.0 / self.bpm) * 1000.0
end

function Conductor:getStepCrotchet()
    return ((60.0 / self.bpm) / self.timeSignature[2]) * 1000.0
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function Conductor:_updateStep(newStep)
    local updated = false
    local newStepFloored = floor(newStep)

    if self.step ~= newStepFloored then
        self.lastStep = self.step
        self.step = newStepFloored
        updated = not (newStepFloored < self.lastStep and self.lastStep - newStepFloored < 2)
    end

    self.stepf = newStep
    return updated
end

---
--- @protected
---
function Conductor:_updateBeat(newBeat)
    local updated = false
    local newBeatFloored = floor(newBeat)

    if self.beat ~= newBeatFloored then
        self.lastBeat = self.beat
        self.beat = newBeatFloored
        updated = true
    end
    
    self.beatf = newBeat
    return updated
end

---
--- @protected
---
function Conductor:_updateMeasure(newMeasure)
    local updated = false
    local newMeasureFloored = floor(newMeasure)

    if self.measure ~= newMeasureFloored then
        self.lastMeasure = self.measure
        self.measure = newMeasureFloored
        updated = true
    end
    
    self.measuref = newMeasure
    return updated
end

---
--- @protected
---
function Conductor._callOnActor(actor, func, ...)
    if actor.getMembers then
        local actorMembers = actor:getMembers() --- @type table<chip.core.Actor>
        for i = 1, actor:getLength() do
            local member = actorMembers[i] --- @type chip.core.Actor
            if member and member:isExisting() and member:isActive() then
                Conductor._callOnActor(member, func, ...)
            end
        end
    end
    if actor[func] then
        actor[func](actor, ...)
    end
end

return Conductor