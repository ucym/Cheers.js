# the actual logic

handleArguments = (env) ->
    if versionFlag and tasks.length == 0
        gutil.log 'CLI version', cliPackage.version

        if env.modulePackage and typeof env.modulePackage.version isnt 'undefined'
            gutil.log 'Local version', env.modulePackage.version
        process.exit 0

    if !env.modulePath
        gutil.log chalk.red('Local gulp not found in'), chalk.magenta(tildify(env.cwd))
        gutil.log chalk.red('Try running: npm install gulp')
        process.exit 1

    if !env.configPath
        gutil.log chalk.red('No gulpfile found')
        process.exit 1
    # check for semver difference between cli and local installation

    if semver.gt(cliPackage.version, env.modulePackage.version)
        gutil.log chalk.red('Warning: gulp version mismatch:')
        gutil.log chalk.red('Global gulp is', cliPackage.version)
        gutil.log chalk.red('Local gulp is', env.modulePackage.version)
    # chdir before requiring gulpfile to make sure
    # we let them chdir as needed

    if process.cwd() isnt env.cwd
        process.chdir env.cwd
        gutil.log 'Working directory changed to', chalk.magenta(tildify(env.cwd))
    # this is what actually loads up the gulpfile
    require env.configPath
    gutil.log 'Using gulpfile', chalk.magenta(tildify(env.configPath))
    gulpInst = require(env.modulePath)
    logEvents gulpInst
    process.nextTick ->

        if simpleTasksFlag
            return logTasksSimple(env, gulpInst)

        if tasksFlag
            return logTasks(env, gulpInst)
        gulpInst.start.apply gulpInst, toRun
        return
    return

logTasks = (env, localGulp) ->
    tree = taskTree(localGulp.tasks)
    tree.label = 'Tasks for ' + chalk.magenta(tildify(env.configPath))

    archy(tree).split('\n').forEach (v) ->
        if v.trim().length == 0
            return
        gutil.log v
        return
    return

logTasksSimple = (env, localGulp) ->
    console.log Object.keys(localGulp.tasks).join('\n').trim()
    return

# format orchestrator errors

formatError = (e) ->
    if !e.err
        return e.message
    # PluginError
    if typeof e.err.showStack == 'boolean'
        return e.err.toString()
    # normal error
    if e.err.stack
        return e.err.stack
    # unknown (string, number, etc.)
    new Error(String(e.err)).stack

# wire up logging events

logEvents = (gulpInst) ->
    # total hack due to poor error management in orchestrator
    gulpInst.on 'err', ->
        failed = true
        return
    gulpInst.on 'task_start', (e) ->
        # TODO: batch these
        # so when 5 tasks start at once it only logs one time with all 5
        gutil.log 'Starting', '\'' + chalk.cyan(e.task) + '\'...'
        return
    gulpInst.on 'task_stop', (e) ->
        time = prettyTime(e.hrDuration)
        gutil.log 'Finished', '\'' + chalk.cyan(e.task) + '\'', 'after', chalk.magenta(time)
        return
    gulpInst.on 'task_err', (e) ->
        msg = formatError(e)
        time = prettyTime(e.hrDuration)
        gutil.log '\'' + chalk.cyan(e.task) + '\'', chalk.red('errored after'), chalk.magenta(time)
        gutil.log msg
        return
    gulpInst.on 'task_not_found', (err) ->
        gutil.log chalk.red('Task \'' + err.task + '\' is not in your gulpfile')
        gutil.log 'Please check the documentation for proper gulpfile formatting'
        process.exit 1
        return
    return

'use strict'
gutil       = require('gulp-util')
prettyTime  = require('pretty-hrtime')
chalk       = require('chalk')
semver      = require('semver')
archy       = require('archy')
Liftoff     = require('liftoff')
tildify     = require('tildify')
interpret   = require('interpret')
v8flags     = require('v8flags')
completion  = require('../lib/completion')
argv        = require('minimist')(process.argv.slice(2))

taskTree    = require('../lib/taskTree')

# set env var for ORIGINAL cwd
# before anything touches it
process.env.INIT_CWD = process.cwd()

cli = new Liftoff(
    name: 'gulp'
    completions: completion
    extensions: interpret.jsVariants
    nodeFlags: v8flags.fetch())

# exit with 0 or 1
failed = false
process.once 'exit', (code) ->
    if code == 0 and failed
        process.exit 1
    return

# parse those args m8
cliPackage = require('../package')
versionFlag = argv.v or argv.version
tasksFlag = argv.T or argv.tasks
tasks = argv._
toRun = if tasks.length then tasks else [ 'default' ]

# this is a hold-over until we have a better logging system
# with log levels
simpleTasksFlag = argv['tasks-simple']
shouldLog = !argv.silent and !simpleTasksFlag
if !shouldLog

    gutil.log = ->

cli.on 'require', (name) ->
    gutil.log 'Requiring external module', chalk.magenta(name)
    return

cli.on 'requireFail', (name) ->
    gutil.log chalk.red('Failed to load external module'), chalk.magenta(name)
    return

cli.on 'respawn', (flags, child) ->
    nodeFlags = chalk.magenta(flags.join(', '))
    pid = chalk.magenta(child.pid)
    gutil.log 'Node flags detected:', nodeFlags
    gutil.log 'Respawned to PID:', pid
    return

cli.launch {
    cwd: argv.cwd
    configPath: argv.gulpfile
    require: argv.require
    completion: argv.completion
} , handleArguments

# ---
# generated by js2coffee 2.0.1
