##|
##|   This is a test to check the timing on the startup cost for the config library
##|

numeral = require 'numeral'
chalk   = require 'chalk'

##|
##| Placeholder for config
config = null

timeFunction = (name, callback)->
    startTime = process.hrtime()
    callback()
    diff      = process.hrtime(startTime)
    ns        = diff[0] * 1e9 + diff[1]
    ms        = ns / 1e6

    console.log "[" + chalk.yellow(name) + "] Total time=", chalk.cyan(numeral(ms).format("#,###.###")), " ms"
    true

try

    timeFunction "Loading Config", ()->
        config = require '../src/Config'

    timeFunction "Logging record", ()->
        config.error "This is an error message"

catch e

    console.log "Exception:", e
