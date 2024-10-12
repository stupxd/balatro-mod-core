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


return YourModName