#!/usr/bin/env coffee

config = require '../src/Config'

testObject =
    name: "Brian Pollack"
    age : 41
    city: "Mooresville"

##|
##|  Get a logger

config.status "Getting logger"
log = config.getLogger "TestLog"

config.status "Running tests"
log.info "Should be logged to the info file", testObject

config.status "Logging to error"
log.error "Should be logged to the error file", testObject

##|  Should have created files
##|
##| ~/EdgeData/logs/TestLog-error.log
##| ~/EdgeData/logs/TestLog-info.log
##| ~/EdgeData/logs/test_logging-trace.log
##|

console.log "Done"

path = require 'path'
console.log "p=", path.basename(process.mainModule.filename)