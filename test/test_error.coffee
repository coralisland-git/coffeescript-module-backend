#!/usr/bin/env coffee

config = require '../src/Config'

testObject =
    name: "Brian Pollack"
    age : 41
    city: "Mooresville"

##|
##|  Get a logger

config.status "Logging to error"
config.error "Should be logged to the error file", testObject

##|  If user is on console, should be seen the error message and continue to log
##|

console.log "Done"