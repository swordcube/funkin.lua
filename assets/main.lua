local fs = love.filesystem
local Script = require("funkin.backend.Script")

function init()
    registerSongs()
    registerLevels()
end

function getModDirectory()
    return "assets/"
end

function registerSongs()
    local songList = table.filter(fs.getDirectoryItems(getModDirectory() .. "/songs"), function(song)
        return fs.getInfo(getModDirectory() .. "/songs/" .. song, "directory")
    end)
    for i = 1, #songList do
        local songID = songList[i] --- @type string
        SongRegistry.instance:registerEntry(songID, Json.parse(File.read(getModDirectory() .. "/songs/" .. songID .. "/meta.json")), modID)
    end
end

function registerLevels()
    local levelList = table.filter(fs.getDirectoryItems(getModDirectory() .. "/data/levels"), function(level)
        return fs.getInfo(getModDirectory() .. "/data/levels/" .. level, "file") and level:endsWith(".json")
    end)
    for i = 1, #levelList do
        local levelID = levelList[i] --- @type string
        LevelRegistry.instance:registerEntry(levelID:sub(1, #levelID - 5), Json.parse(File.read(getModDirectory() .. "/data/levels/" .. levelID)), modID)
    end
end

function onInputReceived(e)
    if e:is(InputEventKey) then
        local keyEvent = e --- @type chip.input.keyboard.InputEventKey
        if keyEvent:getKey() == KeyCode.F5 and keyEvent:isPressed() then
            -- Have to wait a frame before reloading everything
            -- otherwise stupid recursive bullshittery happens
            -- and it endlessly reloads over and over every frame
            -- basically making the game unplayable
            Timer:new():start(0.001, function()
                Engine.paused = false -- Prevent accidental softlocking
                Engine.timeScale = 1.0 -- Prevent accidental softlocking again

                ModLoader.refreshImports()
                print("Refreshed imports")

                ModLoader.updateModList()
                print("Reloaded mod list")

                SongRegistry.instance:clearEntries()
                print("Cleared registered songs")

                LevelRegistry.instance:clearEntries()
                print("Cleared registered levels")

                Cache.clear()
                print("Cleared cache")
    
                ModLoader.reloadMainScripts()
                print("Reloaded all main scripts")
                
                Engine.reloadScene()
                print("Reloaded current scene")
            end)
        end
    end
end

function onSceneInit(scene)
    if scene:is(Gameplay) then
        local game = scene --- @type funkin.scenes.Gameplay

        -- scripts that run in any song
        local globalScripts = table.filter(fs.getDirectoryItems(getModDirectory() .. "/scripts"), function(script)
            return fs.getInfo(getModDirectory() .. "/scripts/" .. script, "file")
        end)
        for i = 1, #globalScripts do
            local script = Script:new(getModDirectory() .. "/scripts/" .. globalScripts[i]) --- @type funkin.backend.Script
            table.insert(game.gameScripts, script)
        end
        
        -- scripts that run only for the current song
        local songScripts = table.filter(fs.getDirectoryItems(getModDirectory() .. "/scripts/songs/" .. game._params.song), function(script)
            return fs.getInfo(getModDirectory() .. "/scripts/songs/" .. game._params.song .. "/" .. script, "file")
        end)
        for i = 1, #songScripts do
            local script = Script:new(getModDirectory() .. "/scripts/songs/" .. game._params.song .. "/" .. songScripts[i]) --- @type funkin.backend.Script
            table.insert(game.gameScripts, script)
        end
    end
end