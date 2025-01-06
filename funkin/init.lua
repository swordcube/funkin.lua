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

Constants = require("funkin.backend.utils.Constants")
CoolUtil = require("funkin.backend.utils.CoolUtil")

Cache = require("funkin.backend.Cache")
Paths = require("funkin.backend.Paths")

Controls = require("funkin.backend.input.Controls")
InputAction = require("funkin.backend.input.InputAction")

Options = require("funkin.backend.Options")
Highscore = require("funkin.backend.Highscore")
Conductor = require("funkin.backend.Conductor")

ModLoader = require("funkin.backend.ModLoader")

AtlasText = require("funkin.ui.AtlasText")
SoundTray = require("funkin.ui.SoundTray")

Gameplay = require("funkin.scenes.Gameplay")

BaseRegistry = require("funkin.backend.registry.BaseRegistry")
SongRegistry = require("funkin.backend.registry.SongRegistry")
LevelRegistry = require("funkin.backend.registry.LevelRegistry")