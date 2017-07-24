tty        = require('tty');
fs         = require 'fs'
argv       = require('yargs').argv;
encrypter  = require 'object-encrypter';
jsonfile   = require 'jsonfile'
numeral    = require 'numeral'
os         = require 'os'
winston    = require 'winston'
exreport   = require 'edgecommonexceptionreport'
ninja      = require 'ninjadebug'
chalk      = require 'chalk'
path       = require 'path'

class EdgeAppConfig

    ##|
    ##| TODO:  These things should be easier to change, load from environment
    ##| or otherwise work from the command line the way trace does.
    ##|

    devMode                 : (process.env.DEVMODE == "true") || false

    traceEnabled            : false
    recordIncomingMessages  : false
    debugAggregateCalls     : !true
    useNinjaDebug           : true
    useExceptionReport      : true

    WebserverPort           : 8001
    WebserverSSLPort        : 8443

    mqExchangePathUpdates   : "all-updates"
    mqExchangeStatusUpdates : "status-updates"
    mqItemUpdates           : "item-updates"
    mqItemUpdatesHigh       : "item-updates-high"
    mqItemUpdatesLow        : "item-updates-low"
    mqItemChanges           : "item-changes"
    mqRetsRawData           : "rets-raw"

    ConfigPath              : [ "./Credentials/", "./", process.env.HOME + "/EdgeConfig/", __dirname, __dirname + "/node_modules/edgecommonconfig/EdgeConfig/", __dirname + "/../EdgeConfig/" ]
    logPath                 : process.env.HOME + "/EdgeData/logs/"
    imagePath               : process.env.HOME + "/EdgeData/images/"
    importPath              : process.env.HOME + "/EdgeData/import/"

    ensureExistsSync : (path) ->
        try
            fs.mkdirSync(path)
        catch e
            if e.code != 'EEXIST' then return false
            return true

        true

    ##|
    ##|  Return and verify a data path
    getDataPath: (pathName) ->

        strPath = process.env.HOME + "/EdgeData/"
        @ensureExistsSync strPath
        for part in pathName.split("/")
            if part.indexOf('.') != -1
                return strPath + part

            strPath += part + "/"
            @ensureExistsSync strPath

        return strPath

    ##|
    ##|  Given a filename and path list, resolve with the full path that exists.
    ##|  @param filename [string] A filename to find
    ##|  @param pathList [array/string] A list of one or more paths to find
    ##|  @return [string] the path and filename that was found.
    ##|
    FindFileInPath: (filename, pathList, returnPath = false)->

        if typeof pathList == "string" then pathList = [ pathList ]
        for pathName in pathList

            try
                if !pathName? then continue
                if pathName.charAt(pathName.length-1) != '/' then pathName += '/'

                filenameTest = pathName + filename
                # console.log "CHECKING[#{filenameTest}]"
                stat = fs.statSync filenameTest            
                if stat? and stat.size and returnPath is false
                    return filenameTest
                if stat? and stat.size and returnPath is true
                    ##|  test for absolute path names
                    if filenameTest.charAt(0) == '/'
                        return path.dirname(filenameTest) + "/"

                    return (path.dirname path.join(process.cwd(), filenameTest)) + '/'
            catch e
                # ...

        return null

    constructor: ()->

        ##|
        ##|  Expose app args
        this.argv = argv

        ##|
        ##|  Put --dev on the command line to use credentials_dev.json
        if argv.dev?
            @devMode = true
        else
            @devMode = false

        ##|
        ##|  General command line flags
        if argv.trace? then @traceEnabled = true

        ##|
        ##|  Currently running app
        @appRunningName = argv['$0']
        @appRunningName = @appRunningName.replace /.*\\/, ""
        @appRunningName = @appRunningName.replace ".coffee", ""
        @appRunningName = @appRunningName.replace "coffee", ""
        @appRunningName = @appRunningName.trim()
        @setTitle @appRunningName

        ##|
        ##|  If we are tracing the app, create a trace logfile.
        ##|
        if @traceEnabled

            @log "Launching ", @appRunningName, " with traceEnabled: ", argv._

            @traceLogFile = new winston.Logger
                transports: [
                    new winston.transports.File
                        level     : "info"
                        filename  : @logPath + @appRunningName + "-trace.log"
                        json      : true
                        timestamp : false
                        depth     : 4
                        tailable  : true
                        showLevel : false
                ]

            @timersRunning = 0
            @timersCount   = 0
            @mainTimer     = @timerStart("Main")

        else

            @mainTimer = null


        ##|
        ##|  If PaperTrail is available, setup exception reporting
        paperTrailConfig = @getCredentials("papertrail")
        if paperTrailConfig?
            require('winston-papertrail').Papertrail;
            paperTrailConfig.level = 'error'
            paperTrailLogger = new winston.transports.Papertrail(paperTrailConfig)
            exreport.winston = new winston.Logger({ transports: [ paperTrailLogger ]})

        ##|
        ##|  General error logging functions
        ##|  Are just like console.log, console.info, console.error
        ##|  Info only shows in verbose mode
        ##|  Error shows in all modes
        ##|  Log if for disoable code testing so it always shows but should not be in production
        @logger        = @getLogger "app"
        this.info      = @logger.info
        this.error     = @logger.error
        this.startTime = new Date()

        if !require.main.__configTrackingEnabled?

            require.main.__configTrackingEnabled = true

            process.on 'exit', @onExitFunction

            process.on 'warning', (warning) =>
                console.warn(warning.name);
                console.warn(warning.message);
                console.warn(warning.stack);

        @getCredentials()

        true

    onExitFunction: (code)=>

        if @traceEnabled
            humanize = require 'humanize-duration'
            console.log "Total duration:", humanize(new Date().getTime()-@startTime.getTime())
            console.log "Application exit code=#{code}"

        @setTitle ""
        return true

    ##|
    ##|  Display an object for debugging purposes
    ##|
    dump : (args...)->
        ninja.dump.apply ninja, args

    ##|
    ##|  Log an internal exception
    reportException: (message, e) =>

        @logger.error "Exception", { message: message, e: e }
        @reportError(message, e)
        true

    ##|
    ##|  Log an exception or error that may be fatal
    reportError : (message, e) =>

        if !e?
            e       = message
            message = ""

        exreport.reportError.apply null, [message, e]
        false

    ##|
    ##| Change the terminal title in iTerm2 and Byobu
    setTitle : (title) ->
        if not Boolean(process.stdout.isTTY) then return

        if title == null
            process.stdout.write String.fromCharCode(27) + "]6;1;bg;*;default" + String.fromCharCode(7)
            process.stdout.write String.fromCharCode(27) + "]2;" + "bash$" + String.fromCharCode(27) + '\\'
        else
            process.stdout.write String.fromCharCode(27) + "]0;" + title + String.fromCharCode(7)
            process.stdout.write String.fromCharCode(27) + "]2;" + title + String.fromCharCode(27) + '\\'

        @appTitle = title
        true

    ##|
    ##|  Report a database error different than other errors
    reportDatabaseError : (name, action, document, e)->

        @logger.error "Database error",
            name: name
            action: action
            document: document
            error: e

        chalk = require 'chalk'
        console.info "--> Database Error"
        console.info chalk.blue "DataSet   :" + chalk.yellow(name)
        console.info chalk.blue "Action    :" + chalk.yellow(action)
        console.info chalk.blue "Document  :" + JSON.stringify(document)
        console.info chalk.blue "Exception :" + chalk.green(e.toString())
        false

    ##|
    ##|  Load credentials from the config file
    ##|  which can be anything that needs very basic security
    ##|  when stored locally on disk or in a git repo.
    ##|  Note: the key.txt file should not be stored in the repo.
    ##|
    getCredentials : (serverCode) =>

        if serverCode? and module.exports[serverCode]?
            return module.exports[serverCode]

        if !@__credentials?
            configFile = @FindFileInPath "key.txt", @ConfigPath
            if !configFile?
                console.log "Error:  Unable to find key.txt in ", @ConfigPath
                return null

            key    = fs.readFileSync configFile
            key    = key.toString()
            engine = encrypter key

            if @devMode
                jsonTextFile = "credentials_dev.json"
            else
                jsonTextFile = "credentials.json"

            configFile = @FindFileInPath jsonTextFile, @ConfigPath
            if !configFile?
                console.log "Error:  Unable to find #{jsonTextFile} in ", @ConfigPath
                return null

            jsonText       = fs.readFileSync configFile
            hex            = JSON.parse(jsonText)
            @__credentials = engine.decrypt(hex)

        if !serverCode?
            for varName, value of @__credentials
                this[varName] = value
            return

        if !@__credentials[serverCode]?
            if serverCode != "papertrail"
                console.error "Warning: requested credentials to unknown site #{serverCode}"
                return null

        return @__credentials[serverCode]

    ##|
    ##|  Set the credentials to credentials.json if given the server and data related to server
    ##|  So this is a shortcut that apps can use for testing.
    ##|
    setCredentials : (serverName, object) ->

        ##| load it so it loads the main config file
        @getCredentials(serverName)

        ##| now store a new value
        @__credentials[serverName] = object;
        return

    ##|
    ##|  Returns a reference to a logger object
    ##|  given a specific name which is cached across multiple calls.
    ##|
    getLogger : (name)->

        if !@__logs?
            @__logs = {}

        consoleLevel = "log"
        if @traceEnabled then consoleLevel = "info,log,error"

        if !@__logs[name]?

                infoLogFile = @getDataPath "logs/#{name}-info.log"
                errorLogFile = @getDataPath "logs/#{name}-error.log"

                transportList = transports: [
                    new winston.transports.Console
                        level       : consoleLevel
                        colorize    : true
                        prettyPrint : true
                        depth       : 4
                        timestamp   : true
                        showLevel   : false
                ,
                    new winston.transports.File
                        name          : "info"
                        level         : "info"
                        filename      : infoLogFile
                        json          : true
                        timestamp     : true
                        maxsize       : 1024*1024*40
                        maxFiles      : 10
                        depth         : 4
                        tailable      : true
                        zippedArchive : true
                        showLevel     : false
                ,
                    new winston.transports.File
                        name          : "error"
                        level         : "error"
                        filename      : errorLogFile
                        json          : true
                        timestamp     : true
                        maxsize       : 1024*1024*40
                        maxFiles      : 10
                        depth         : 4
                        tailable      : true
                        zippedArchive : true
                        showLevel     : false
                ]
                exitOnError: false

                ##|
                ##|  Support for papertrail
                paperTrailConfig = @getCredentials("papertrail")
                if paperTrailConfig?

                    if !@appTitle? or @appTitle == ""
                        @appTitle = path.basename(process.mainModule.filename)

                    paperTrailConfig.level = 'error'
                    paperTrailConfig.program = @appTitle
                    paperTrailConfig.colorize = true
                    paperTrailLogger = new winston.transports.Papertrail(paperTrailConfig)
                    transportList.transports.push paperTrailLogger

                if @traceEnabled
                    conerror = new winston.transports.Console
                        level       : 'error'
                        colorize    : true
                        prettyPrint : true
                        depth       : 4
                        timestamp   : true
                        showLevel   : false

                    transportList.transports.push conerror

                @__logs[name] = new winston.Logger(transportList)

        return @__logs[name]

    log: (message...)=>
        console.log.apply null, message

    status: (message...)=>
        if @mainTimer?
            @mainTimer.status.apply @mainTimer, message
        true

    ##|
    ##|  Start a timer (benchmark) and return the benchmark details
    ##|
    timerStart : (name)=>

        if not @traceEnabled
            data = {}
            data.log = ()-> return false
            data.status = ()-> return false
            return data

        data              = {}
        data.name         = name
        data.lastTime     = process.hrtime()
        data.totalTime    = 0
        data.lastStatus   = "Starting " + name
        data.timerNumber  = @timersCount++
        data.traceLogFile = @traceLogFile

        data.log = (status)->

            diff = process.hrtime(this.start)
            ns   = diff[0] * 1e9 + diff[1]
            ms   = ns / 1e6

            if !status? then status = "Undefined status"

            segment   = process.hrtime(this.lastTime)
            segmentns = segment[0] * 1e9 + segment[1]
            segmentms = segmentns / 1e6

            this.totalTime  = this.totalTime + segmentms

            this.traceLogFile.info
                timer     : name
                segmentms : segmentms
                totalms   : this.totalTime
                timer_id  : this.timerNumber
                lastCall  : this.lastStatus
                thisCall  : status

            this.lastStatus = status
            this.lastTime   = process.hrtime()
            return segmentms

        data.status = (statusAll...)->

            if statusAll? and statusAll.length == 1 and typeof statusAll[0] == "string"
                status = statusAll[0]
            else
                status = ""
                for obj in statusAll

                    if typeof obj == "string"
                        status = status + obj
                    else
                        status = status + ninja.dumpVar obj, ""

                # status = ninja.dumpVar statusAll, ""
                # status = status[0..300].replace("\n", ", ")

            segmentms = this.log(status)
            str = ""

            if segmentms > 5000
                str = "[" + ninja.pad(segmentms / 1000, 13, chalk.red) + " sec] "
            else if segmentms > 1000
                str = "[" + ninja.pad(segmentms / 1000, 13, chalk.yellow) + " sec] "
            else
                str = "[" + ninja.pad(segmentms, 14) + " ms] "

            console.log "#{str} #{name} | #{status}"

        return data
        true

##|
##|  Return a reference to the app configuration
module.exports = new EdgeAppConfig()