---@diagnostic disable: invisible
---
--- @class funkin.objects.ui.alphabet.AlphabetGlyph : flora.display.Sprite
---
local AlphabetGlyph = Sprite:extend("AlphabetGlyph", ...)

AlphabetGlyph.Y_PER_POW = 60.0
AlphabetGlyph.LETTERS = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
AlphabetGlyph.ALL_GLYPHS = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "#", "$", "%", "&", "(", ")", "[", "]", "|", "~", "<", ">", " ", "←", "↓", "↑", "→", "-", "_", "!", "'", ",", ".", ":", ";", "+", "?", "*", "^", "\\", "/", "\"", "=", "×", "♥"}
AlphabetGlyph.CONVERSION_TABLE = {
    ["\\"] = "backslash",
    ["/"] = "forward slash",
    [","] = "comma",
    ["!"] = "exclamation mark",
    ["←"] = "left arrow",
    ["↓"] = "down arrow",
    ["↑"] = "up arrow",
    ["→"] = "right arrow",
    ["×"] = "multiply x",
    ["♥"] = "heart",
    ["\""] = "start parentheses",
    ["%"] = "percent",
    ["$"] = "dollar",
    ["&"] = "and",
    ["#"] = "hashtag",
    [":"] = "colon",
    [";"] = "semicolon"
}

---
--- @param  parent  funkin.objects.ui.alphabet.Alphabet
--- @param  x       number?
--- @param  y       number?
--- @param  char    string
--- @param  type    "bold"|"normal"
---
function AlphabetGlyph:constructor(parent, x, y, char, type)
    AlphabetGlyph.super.constructor(self, x, y)

    ---
    --- @type funkin.objects.ui.alphabet.Alphabet
    ---
    self.parent = parent

    ---
    --- @type string
    ---
    self.type = nil

    ---
    --- @type string
    ---
    self.char = nil

    ---
    --- @type integer
    ---
    self.row = 0

    ---
    --- @type flora.math.Vector2
    ---
    self.spawnPos = Vector2:new()

    ---
    --- @protected
    --- @type string
    ---
    self._type = type

    ---
    --- @protected
    --- @type string
    ---
    self._char = char

    self:set_char(char)
end

function AlphabetGlyph.convert(char)
    local converted = AlphabetGlyph.CONVERSION_TABLE[char]
    return converted and converted or char
end

function AlphabetGlyph:dispose()
	self.parent = nil
    AlphabetGlyph.super.dispose(self)
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function AlphabetGlyph:updateBoldOffset()
    local offset = Vector2:new(0, 0)
    local char_sets = {
        {
            chars = {"$", "%", "&", "(", ")", "[", "]", "<", ">"},
            offset = Vector2:new(0, self.frameHeight * 0.1)
        },
        {
            chars = {"#", "←", "↓", "↑", "→", "+", "=", "×", "♥"},
            offset = Vector2:new(0, self.frameHeight * 0.2)
        },
        {
            chars = {",", "."},
            offset = Vector2:new(0, self.frameHeight * 0.65)
        },
        {
            chars = {"~"},
            offset = Vector2:new(0, self.frameHeight * 0.3)
        },
        {
            chars = {"-"},
            offset = Vector2:new(0, self.frameHeight * 0.3)
        },
        {
            chars = {"_"},
            offset = Vector2:new(0, self.frameHeight * 0.6)
        }
    }
    for i = 1, #char_sets do
        local set = char_sets[i]
        for j = 1, #set.chars do
            if self._char == set.chars[j] then
                offset.x = offset.x + set.offset.x
                offset.y = offset.y + set.offset.y
                break
            end
        end
    end
    self.animation:setOffset("idle", -offset.x, -offset.y)
    self.animation:play("idle", true)
end

---
--- @protected
---
function AlphabetGlyph:updateOffset()
    local offset = Vector2:new(0, 110 - self.frameHeight)
    local char_sets = {
        {
            chars = {"a", "c", "e", "g", "m", "n", "o", "r", "u", "v", "w", "x", "z", "s"},
            offset = Vector2:new(0, self.frameHeight * 0.25)
        },
        {
            chars = {"$", "%", "&", "(", ")", "[", "]", "<", ">"},
            offset = Vector2:new(0, self.frameHeight * 0.1)
        },
        {
            chars = {"#", "←", "↓", "↑", "→", "+", "=", "×", "♥"},
            offset = Vector2:new(0, self.frameHeight * 0.2)
        },
        {
            chars = {",", "."},
            offset = Vector2:new(0, self.frameHeight * 0.7)
        },
        {
            chars = {"~"},
            offset = Vector2:new(0, self.frameHeight * 0.3)
        },
        {
            chars = {"-"},
            offset = Vector2:new(0, self.frameHeight * 0.32)
        },
        {
            chars = {"_"},
            offset = Vector2:new(0, self.frameHeight * 0.65)
        },
        {
            chars = {"p", "q", "y"},
            offset = Vector2:new(0, self.frameHeight * 0.22)
        }
    }
    for i = 1, #char_sets do
        local set = char_sets[i]
        for j = 1, #set.chars do
            if self._char == set.chars[j] then
                offset = offset + set.offset
                break
            end
        end
    end
    self.animation:setOffset("idle", -offset.x, -offset.y)
    self.animation:play("idle", true)
end

---
--- @protected
---
function AlphabetGlyph:get_char()
    return self._char
end

---
--- @protected
---
function AlphabetGlyph:get_type()
    return self._type
end

---
--- @protected
---
function AlphabetGlyph:set_char(val)
    self._char = val
    self.frames = Paths.getSparrowAtlas(self._type, "images/menus/fonts")

    local isLetter = table.contains(AlphabetGlyph.LETTERS, self._char)
    local converted = AlphabetGlyph.convert(self._char)

    if self._type ~= "bold" and isLetter then
        local letter_case = (self._char:lower() ~= self._char) and "capital" or "lowercase"
        converted = converted:upper() .. " " .. letter_case
    end
    self.animation:addByPrefix("idle", converted:upper() .. "0", 24)
    
    if not self.animation:exists("idle") then
        self.animation:addByPrefix("idle", converted .. "0", 24)
    end
    if not self.animation:exists("idle") then
        Flora.log:warn('Letter in ' .. self._type .. ' alphabet: ' .. converted .. ' doesn\'t exist!');
        self.animation:addByPrefix("idle", "?0", 24)
    end
    self.animation:play("idle")

    if self._type == "bold" then
        self:updateBoldOffset()
    else
        self:updateOffset()
    end
    return self._char
end

---
--- @protected
---
function AlphabetGlyph:set_type(val)
    self._type = val
    self:set_char(self._char)
    return self._type
end

return AlphabetGlyph