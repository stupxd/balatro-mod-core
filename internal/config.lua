
local config_loaded = false

YourModName.save_config = function ()
    if not config_loaded then
        YourModName.log "Cannot save config as it was never loaded"
        return
    end

    YourModName.log "Saving your-mod-name config..."
    love.filesystem.write('config/your-mod-name.jkr', "return " .. YourModName.dump(YourModName.SETTINGS))
end


YourModName.load_config = function ()
    config_loaded = true

    YourModName.log "Starting to load config"
    if not love.filesystem.getInfo('config') then
        YourModName.log("Creating config folder...")
        love.filesystem.createDirectory('config')
    end

    -- Steamodded config file location
    local config_file = love.filesystem.read('config/your-mod-name.jkr')

    local latest_default_config = YourModName.load_mod_file('config.lua', 'default-config')

    if config_file then
        YourModName.log "Reading config file: "
        YourModName.log(config_file)
        YourModName.SETTINGS = STR_UNPACK(config_file) -- Use STR_UNPACK to avoid code injectons via config files
    else
        YourModName.log "Creating default settings"
        YourModName.SETTINGS = latest_default_config
        YourModName.save_config()
    end

    -- Remove unused settings
    for k, v in pairs(YourModName.SETTINGS) do
        if latest_default_config[k] == nil then
            YourModName.log("Removing setting `"..k.. "` because it is not in default config")
            YourModName.SETTINGS[k] = nil
        end
    end

    for k, v in pairs(latest_default_config) do
        if YourModName.SETTINGS[k] == nil then
            YourModName.log("Adding setting `"..k.. "` because it is missing in latest config")
            YourModName.SETTINGS[k] = v
        end
    end
end

local cart_options_ref = G.FUNCS.options
G.FUNCS.options = function(e)
    if YourModName.INTERNAL_in_config then
        YourModName.INTERNAL_in_config = false
        YourModName.save_config()
    end
    return cart_options_ref(e)
end
