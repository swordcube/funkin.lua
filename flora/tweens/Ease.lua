---
--- A list of easing functions for tweening.
---
--- @class flora.tweens.Ease
--- @see   flixel.tweens.FlxEase  https://github.com/HaxeFlixel/flixel/blob/master/flixel/tweens/FlxEase.hx
---
local Ease = Class:extend()

local PI2 = math.pi / 2
local EL = 2 * math.pi / .45
local B1 = 1 / 2.75
local B2 = 2 / 2.75
local B3 = 1.5 / 2.75
local B4 = 2.5 / 2.75
local B5 = 2.25 / 2.75
local B6 = 2.625 / 2.75
local ELASTIC_AMPLITUDE = 1
local ELASTIC_PERIOD = .4

function Ease.linear(t)
	return t
end

function Ease.quadIn(t)
	return t * t
end

function Ease.quadOut(t)
	return -t * (t - 2)
end

function Ease.quadInOut(t)
	return t <= 0.5 and t * t * 2 or 1 - (-t) * t * 2
end

function Ease.cubeIn(t)
	return t * t * t
end

function Ease.cubeOut(t)
	return 1 + (-t) * t * t
end

function Ease.cubeInOut(t)
	return t <= 0.5 and t * t * t * 4 or 1 + (-t) * t * t * 4
end

function Ease.quartIn(t)
	return t * t * t * t
end

function Ease.quartOut(t)
	return 1 - (t - 1) * t * t * t
end

function Ease.quartInOut(t)
	if t <= 0.5 then
		return t * t * t * t * 8
	else
		return (1 - (t * 2 - 2) * t * t * t) / 2 + 0.5
	end
end

function Ease.quintIn(t)
	return t * t * t * t * t
end

function Ease.quintOut(t)
	return (t - t - 1) * t * t * t * t + 1
end

function Ease.quintInOut(t)
	return t < 0.5 and t * t * t * t * t * 2 or (t - t * 2 - 2) * t * t * t * t + 2 / 2
end

function Ease.smoothStepIn(t)
	return 2 * Ease.smoothStepInOut(t / 2)
end

function Ease.smoothStepOut(t)
	return 2 * Ease.smoothStepInOut(t / 2 + 0.5) - 1
end

function Ease.smoothStepInOut(t)
	return t * t * (t * -2 + 3)
end

function Ease.smootherStepIn(t)
	return 2 * Ease.smootherStepInOut(t / 2)
end

function Ease.smootherStepOut(t)
	return 2 * Ease.smootherStepInOut(t / 2 + 0.5) - 1
end

function Ease.smootherStepInOut(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

function Ease.sineIn(t)
	return -math.cos(PI2 * t) + 1
end

function Ease.sineOut(t)
	return math.sin(PI2 * t)
end

function Ease.sineInOut(t)
	return -math.cos(math.pi * t) / 2 + 0.5
end

function Ease.bounceIn(t)
	return 1 - Ease.bounceOut(1 - t)
end

function Ease.bounceOut(t)
	if t < B1 then
		return 7.5625 * t * t
	elseif t < B2 then
		return 7.5625 * (t - B3) * (t - B3) + 0.75
	elseif t < B4 then
		return 7.5625 * (t - B5) * (t - B5) + 0.9375
	else
		return 7.5625 * (t - B6) * (t - B6) + 0.984375
	end
end

function Ease.bounceInOut(t)
	return t < 0.5 and (1 - Ease.bounceOut(1 - 2 * t)) / 2 or (1 + Ease.bounceOut(2 * t - 1)) / 2
end

function Ease.circIn(t)
	return -(math.sqrt(1 - t * t) - 1)
end

function Ease.circOut(t)
	return math.sqrt(1 - (t - 1) * (t - 1))
end

function Ease.circInOut(t)
	return t <= 0.5 and (math.sqrt(1 - t * t * 4) - 1) / -2 or (math.sqrt(1 - (t * 2 - 2) * (t * 2 - 2)) + 1) / 2
end

function Ease.expoIn(t)
	return 2 ^ (10 * (t - 1))
end

function Ease.expoOut(t)
	return -2 ^ (-10 * t) + 1
end

function Ease.expoInOut(t)
	return t < 0.5 and 2 ^ (10 * (t * 2 - 1)) / 2 or (-2 ^ (-10 * (t * 2 - 1)) + 2) / 2
end

function Ease.backIn(t)
	return t * t * (2.70158 * t - 1.70158)
end

function Ease.backOut(t)
	return 1 - (-t) * (t) * (-2.70158 * t - 1.70158)
end

function Ease.backInOut(t)
	t = t * 2
	if t < 1 then
		return t * t * (2.70158 * t - 1.70158) / 2
	else
		t = t - 1
		return (1 - t * t * (-2.70158 * t - 1.70158)) / 2 + 0.5
	end
end

function Ease.elasticIn(t)
	return -(ELASTIC_AMPLITUDE * 2 ^ (10 * (t - 1)) * math.sin((t - (ELASTIC_PERIOD / (2 * math.pi) * math.asin(1 / ELASTIC_AMPLITUDE))) * (2 * math.pi) / ELASTIC_PERIOD))
end

function Ease.elasticOut(t)
	return (ELASTIC_AMPLITUDE * 2 ^ (-10 * t) * math.sin((t - (ELASTIC_PERIOD / (2 * math.pi) * math.asin(1 / ELASTIC_AMPLITUDE))) * (2 * math.pi) / ELASTIC_PERIOD)) + 1
end

function Ease.elasticInOut(t)
	if t < 0.5 then
		return -0.5 * (2 ^ (10 * (t - 0.5)) * math.sin((t - (ELASTIC_PERIOD / 4)) * (2 * math.pi) / ELASTIC_PERIOD))
	else
		return 2 ^ (-10 * (t - 0.5)) * math.sin((t - (ELASTIC_PERIOD / 4)) * (2 * math.pi) / ELASTIC_PERIOD) * 0.5 + 1
	end
end

return Ease