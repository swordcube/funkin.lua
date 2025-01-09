local fs = love.filesystem

function init()
    registerSongs()
    registerLevels()
end

function registerSongs()
    local songList = table.filter(fs.getDirectoryItems("assets/songs"), function(song)
        return fs.getInfo("assets/songs/" .. song, "directory")
    end)
    for i = 1, #songList do
        local songID = songList[i] --- @type string
        SongRegistry.instance:registerEntry(songID, Json.parse(File.read("assets/songs/" .. songID:lower() .. "/meta.json")))
    end
end

function registerLevels()
    local levelList = table.filter(fs.getDirectoryItems("assets/data/levels"), function(level)
        return fs.getInfo("assets/data/levels/" .. level, "file") and level:endsWith(".json")
    end)
    for i = 1, #levelList do
        local levelID = levelList[i] --- @type string
        LevelRegistry.instance:registerEntry(levelID:sub(1, #levelID - 5), Json.parse(File.read("assets/data/levels/" .. levelID)))
    end
end

function onInputReceived(e)
    if e:is(InputEventKey) then
        local keyEvent = e --- @type chip.input.InputEventKey
        if keyEvent:getKey() == KeyCode.F5 and keyEvent:isPressed() then
            -- Have to wait a frame before reloading everything
            -- otherwise stupid recursive bullshittery happens
            -- and it endlessly reloads over and over every frame
            -- basically making the game unplayable
            Timer:new():start(0.001, function()
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