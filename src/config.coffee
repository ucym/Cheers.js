fs      = require "fs"
path    = require "path"

platform = switch
    when /^win/.test(process.platform) then "windows"
    when process.platform == 'darwin' then "mac"
    else "linux"

appDataDir = switch platform
    when "windows" then process.env.APPDATA
    when "mac" then process.env.HOME
    when "linux" then '/var/local/'

module.exports =
    platform    : platform
    paths       :
        appData             : appDataDir

        cheersModules       : path.join __dirname, "../node_modules"
        cheersData          : path.join appDataDir, ".cheers"
        cheersPublicModules : path.join appDataDir, ".cheers", "node_modules"

    bins        :
        gulp                : path.join path.dirname(fs.realpathSync(__filename)), "../node_modules/.bin/gulp"
