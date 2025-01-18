speedTextTween = nil --- @type chip.tweens.Tween
ohGod = false

function onInitPost()
    speedText = Text:new(0, Engine.gameHeight * 0.75, 0, "Speed: 1", 24) --- @type chip.graphics.Text
    speedText:setFont(Paths.font("vcr.ttf"))
    speedText:setBorderSize(3)
    speedText:setBorderColor(Color.BLACK)
    speedText:screenCenter("x")
    speedText:setFastRendering(false)
    speedText:setAlpha(0.0)
    game.hudLayer:add(speedText)
end

function onUpdate(dt)
    if ohGod then
        game:setPlaybackRate(game:getPlaybackRate() - (dt * 0.25))
    end
end

function setLeSpeed(speed)
    game:setPlaybackRate(math.truncate(speed, 2))
    speedText:setContents("Speed: " .. math.truncate(speed, 2))
    speedText:screenCenter("x")
    
    speedText:setAlpha(1.0)
    
    if speedTextTween then
        speedTextTween:free()
    end
    speedTextTween = Tween:new() --- @type chip.tweens.Tween
    speedTextTween:tweenProperty(speedText, "alpha", 0.0, 0.3):setStartDelay(2.0)
end

function onInputReceived(_)
    local amount = (Input.isKeyPressed(KeyCode.L_SHIFT) or Input.isKeyPressed(KeyCode.R_SHIFT)) and 0.25 or 0.01
    if Input.wasKeyJustPressed(KeyCode.PAGE_DOWN) then
        setLeSpeed(math.truncate(game:getPlaybackRate() - amount, 2))
    end
    if Input.wasKeyJustPressed(KeyCode.PAGE_UP) then
        setLeSpeed(math.truncate(game:getPlaybackRate() + amount, 2))
    end
    if Input.wasKeyJustPressed(KeyCode.GRAVE_ACCENT) then
        ohGod = not ohGod
    end
    if Input.wasKeyJustPressed(KeyCode.DELETE) then
        game:setPlaybackRate(1.0)
    end
end

function onBeatHit(b)
    local r = math.preciseRandom(0.500, 2.000)
    local t = Tween:new() --- @type chip.tweens.Tween
    t:tweenProperty(Engine, "timeScale", r, Conductor.instance:getCrotchet() / 1000):setEase(Ease.sineOut):setUpdateCallback(function(t)
        game:setPlaybackRate(t:getValue())
    end)
end