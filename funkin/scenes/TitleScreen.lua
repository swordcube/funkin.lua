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
--- @class funkin.scenes.TitleScreen : chip.core.Scene
---
local TitleScreen = Scene:extend("TitleScreen", ...)

function TitleScreen:init()
    self:setUpdateMode("always")

    self.beatCallbacks = {
        [1] = function()
            self:createCoolText({"The", "Funkin Crew Inc"})
        end,
        [3] = function()
            self:createCoolText({"The", "Funkin Crew Inc", "Presents"})
        end,
        [4] = function()
            self:deleteCoolText()
        end,
        [5] = function()
            self:createCoolText({"In association", "with"})
        end,
        [7] = function()
            self:createCoolText({"In association", "with", "Newgrounds"})
            if self.ngSpr then
                self.ngSpr:revive()
            end
        end,
        [8] = function()
            self:deleteCoolText()
            if self.ngSpr then
                self:remove(self.ngSpr)
                self.ngSpr:kill()
            end
        end,
        [9] = function()
            self:createCoolText({self.introTexts[1]})
        end,
        [11] = function()
            self:createCoolText({self.introTexts[1], self.introTexts[2]})
        end,
        [12] = function()
            self:deleteCoolText()
        end,
        [13] = function()
            self:createCoolText({"Friday"})
        end,
        [14] = function()
            self:createCoolText({"Friday", "Night"})
        end,
        [15] = function()
            self:createCoolText({"Friday", "Night", "Funkin"})
        end
    }
    self.introLength = 16
    self.danced = false

    local lines = CoolUtil.parseCSV(File.read(Paths.csv("introText")))
    self.introTexts = lines[math.random(1, #lines)]

    if not BGM.isPlaying() then
        CoolUtil.playMenuMusic(0)
        BGM.fade(0, 1, 4)
    end

    self.titleGroup = Group:new() --- @type chip.core.Group
    self.titleGroup:kill()
    self:add(self.titleGroup)

    self.logoBl = Sprite:new(-150, -100) --- @type chip.graphics.Sprite
    self.logoBl:setFrames(Paths.getSparrowAtlas("logo", "images/menus/title"))
    self.logoBl.animation:addByPrefix("idle", "logo bumpin", 24, false)
    self.logoBl.animation:play("idle")
    self.titleGroup:add(self.logoBl)

    self.gfDance = Sprite:new(Engine.gameWidth * 0.4, Engine.gameHeight * 0.07) --- @type chip.graphics.Sprite
    self.gfDance:setFrames(Paths.getSparrowAtlas("gf", "images/menus/title"))
    self.gfDance.animation:addByIndices("danceLeft", "gfDance", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15}, 24, false)
    self.gfDance.animation:addByIndices("danceRight", "gfDance", {16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30}, 24, false)
    self.gfDance.animation:play("danceLeft")
    self.titleGroup:add(self.gfDance)

    self.titleText = Sprite:new(100, Engine.gameHeight * 0.8) --- @type chip.graphics.Sprite
    self.titleText:setFrames(Paths.getSparrowAtlas("enter", "images/menus/title"))
    self.titleText.animation:addByPrefix("idle", "Press Enter to Begin", 24)
    self.titleText.animation:addByPrefix("press", "ENTER PRESSED", 24, false)
    self.titleText.animation:play("idle")
    self.titleGroup:add(self.titleText)

    self.introText = AtlasText:new(0, 200, "bold", "center", "") --- @type funkin.ui.AtlasText
    self.introText:screenCenter("x")
    self:add(self.introText)

    self.ngSpr = Sprite:new(0, Engine.gameHeight * 0.52) --- @type chip.graphics.Sprite
    
    if math.random(1.0, 100.0) < 1 then
        self.ngSpr:loadTexture(Paths.image('newgrounds_classic', "images/menus/title"))
    
    elseif math.random(1.0, 100.0) < 30 then
        self.ngSpr:loadTexture(Paths.image('newgrounds_animated', "images/menus/title"), true, 600)
        self.ngSpr.animation:add('idle', {1, 2}, 8)
        self.ngSpr.animation:play('idle')
        self.ngSpr.scale:set(0.55, 0.55)
        self.ngSpr:setY(self.ngSpr:getY() + 15)
    else
        self.ngSpr:loadTexture(Paths.image('newgrounds', "images/menus/title"))
        self.ngSpr.scale:set(0.8, 0.8)
    end
    self.ngSpr:kill()
    self.ngSpr:screenCenter("x")
    self:add(self.ngSpr)

    self.flashSpr = Sprite:new() --- @type chip.graphics.Sprite
    self.flashSpr:makeSolid(Engine.gameWidth, Engine.gameHeight, Color.WHITE)
    self.flashSpr:screenCenter("xy")
    self.flashSpr:kill()
    self:add(self.flashSpr)

    self.flashTween = nil --- @type chip.tweens.Tween
end

function TitleScreen:deleteCoolText()
    self.introText:kill()
end

function TitleScreen:createCoolText(lines)
    if #lines == 0 then
        self.introText:kill()
        return
    end
    local text = lines[1]
    for i = 2, #lines do
        local line = lines[i]
        text = text .. "\n" .. line
    end
    self.introText:revive()
    self.introText:setContents(text:trim())
    self.introText:screenCenter("x")
end

function TitleScreen:skipIntro()
    if self.skippedIntro then
        return
    end
    if self.ngSpr then
        self.ngSpr:kill()
    end
    self.skippedIntro = true
    self.titleGroup:revive()

    self:deleteCoolText()
    self.flashSpr:revive()

    if self.flashTween then
        self.flashTween:free()
    end
    self.flashTween = Tween:new() --- @type chip.tweens.Tween
    self.flashTween:tweenProperty(self.flashSpr, "alpha", 0, 4)
    self.flashTween:setCompletionCallback(function(_)
        self.flashSpr:kill()
        self.flashTween = nil
    end)
end

function TitleScreen:input(_)
    if Controls.justPressed.ACCEPT then
        if not self.skippedIntro then
            self:skipIntro()
        else
            if not self.accepted then
                self.accepted = true
                if not self.flashTween then
                    self.flashSpr:revive()
                    self.flashSpr:setAlpha(1.0)

                    self.flashTween = Tween:new() --- @type chip.tweens.Tween
                    self.flashTween:tweenProperty(self.flashSpr, "alpha", 0, 4)
                    self.flashTween:setCompletionCallback(function(_)
                        self.flashSpr:kill()
                        self.flashTween = nil
                    end)
                end
                self._acceptTimer = Timer:new():start(2, function(_)
                    self:setUpdateMode("inherit")
                    Engine.switchScene(require("funkin.scenes.MainMenu"):new())
                end)
                self.titleText.animation:play("press")
                AudioPlayer.playSFX(Paths.sound("select", "sounds/menus"))
            else
                if self._acceptTimer then
                    self._acceptTimer:free()
                    self._acceptTimer = nil
                end
                self:setUpdateMode("inherit")
                Engine.switchScene(require("funkin.scenes.MainMenu"):new())
            end
        end
    end
end

function TitleScreen:beatHit(beat)
    if not self.skippedIntro then
        if self.beatCallbacks[beat] then
            self.beatCallbacks[beat]()
        end
        if beat >= self.introLength then
            self:skipIntro()
        end
    end
    self.danced = not self.danced
    if not self.danced then
        self.gfDance.animation:play("danceLeft", true)
    else
        self.gfDance.animation:play("danceRight", true)
    end
    self.logoBl.animation:play("idle", true)
end

return TitleScreen