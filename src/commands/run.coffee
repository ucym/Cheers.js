###
# "Default" command
###

fs          = require "fs"
path        = require "path"
spawn       = require("child_process").spawn
Module      = require "module"

argv        = require "argv"
coffee      = require "coffee-script"

#-- initialize
cheersEnv = require "../config"


# Register node_modules dirpath for cheersjs
Module.globalPaths.push cheersEnv.paths.cheersModules
Module.globalPaths.push cheersEnv.paths.cheersPublicModules
Module.globalPaths.push path.join(cheersEnv.paths.cheersModules, "gulp")

module.exports = (args) ->
    config =
        command : null
        args    : null

    if cheersEnv.platform is "windows"
        config.command = "cmd"
        config.args = ["/c", cheersEnv.bins.gulp]
    else if cheersEnv.platform is "mac"
        config.command = cheersEnv.bins.gulp
        config.args = []

    Array::push.apply config.args, args.targets

    coffee.register()

    #
    cwd = process.cwd() + "/"
    # console.log cwd
    # require cheersEnv.bins.gulp
    require "../gulp"

    # if fs.existsSync(cwd + "Gulpfile.js")
    #     require cwd + "Gulpfile"
    # else if fs.existsSync(cwd + "Gulpfile.coffee")
    #     require cwd + "Gulpfile.coffee"

    # env = process.env
    # env.modulePath = cheersEnv.paths.cheersPublicModules
    # proc = spawn config.command, config.args,
    #     stdio       : "inherit"
        # env         :
        #     modulePath      : cheersEnv.paths.cheersModules

        # cwd         :
