YourModName = {}
YourModName.INTERNAL_debugging = false

YourModName.SETTINGS = {}

YourModName.nfs = require "your-mod-name.nfs"
local lovely = require "lovely"

YourModName.use_smods = function ()
    return SMODS and not (MODDED_VERSION == "0.9.8-STEAMODDED")
end


YourModName.find_self = function (target_filename)
    local mods_path = lovely.mod_dir

	local mod_folders = YourModName.nfs.getDirectoryItems(mods_path)
    for _, folder in pairs(mod_folders) do
        local path = string.format('%s/%s', mods_path, folder)
        local files = YourModName.nfs.getDirectoryItems(path)

        for _, filename in pairs(files) do
            if filename == target_filename then
                return path
            end
        end
    end
end

YourModName.path = YourModName.find_self('your-mod-name.lua')
assert(YourModName.path, "Failed to find mod folder. Make sure that `YourModName` folder has `your-mod-name.lua` file!")

YourModName.load_mod_file = function (path, name)
    name = name or path

    local file, err = YourModName.nfs.read(YourModName.path..'/'..path)

    assert(file, string.format([=[[YourModName] Failed to load mod file %s (%s).:
%s]=], path, name, tostring(err)))

    return load(file, string.format(" YourModName - %s ", name))()
end

YourModName.log = function (msg)
    if YourModName.INTERNAL_debugging then
        local msg = type(msg) == "string" and msg or YourModName.dump(msg)

        print("[YourModName] "..msg)
    end
end

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

return YourModName