
YourModName.dump = function (o, level, prefix)
    level = level or 1
    prefix = prefix or '  '
    if type(o) == 'table' and level <= 5 then
        local s = '{ \n'
        for k, v in pairs(o) do
            local format
            if type(k) == 'number' then
                format = '%s[%d] = %s,\n'
            else
                format = '%s["%s"] = %s,\n'
            end
            s = s .. string.format(
                    format,
                    prefix,
                    k,
                    -- Compact parent & draw_major to avoid recursion and huge dumps.
                    (k == 'parent' or k == 'draw_major') and string.format("'%s'", tostring(v)) or YourModName.dump(v, level + 1, prefix..'  ')
            )
        end
        return s..prefix:sub(3)..'}'
    else
        if type(o) == "string" then
            return string.format('"%s"', o)
        end

        if type(o) == "function" or type(o) == "table" then
            return string.format("'%s'", tostring(o))
        end

        return tostring(o)
    end
end

local config_loaded = false

YourModName.save_config = function ()
    if not config_loaded then
        YourModName.log "Cannot save config as it was never loaded"
        return
    end

    YourModName.log "Saving your-mod-name config..."
    YourModName.nfs.write('config/your-mod-name.jkr', "return " .. YourModName.dump(YourModName.SETTINGS))
end


YourModName.load_config = function ()
    config_loaded = true

    YourModName.log "Starting to load config"
    if not YourModName.nfs.getInfo('config') then
        YourModName.log("Creating config folder...")
        YourModName.nfs.createDirectory('config')
    end

    -- Steamodded config file location
    local config_file = YourModName.nfs.read('config/your-mod-name.jkr')

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
