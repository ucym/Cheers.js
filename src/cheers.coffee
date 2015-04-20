spwan   = require("child_process").spawn

argv    = require "argv"

commandProxies =
    help        : ->
        console.log """

        Usage: cheers [command] [args]

        Commands
        \tinstall\t\tInstall gulp module into cheers module dir
        \thelp\t\t\tShow this help.
        """

    run     : (args) ->
        require("./commands/run")(args)

    install     : (args) ->


module.exports = ->
        Array::forEach.call [
            mod         : "run"
            description : "Run gulp"
            options     : [
                name        : "task"
                short       : "t"
                type        : "string"
                description : "Specify gulp's entry task"
            ]
        ,
            mod         : "install"
            description : ""
            options     : []
        ,
            mod         : "help"
            description : ""
            options     : []
        ], argv.mod


        args =  argv.run()
        command = args.mod
        command = "run" if not command?
        command = "help" if not command?

        if commandProxies[command]?
            commandProxies[command]?(args)
        else
            commandProxies.help()
