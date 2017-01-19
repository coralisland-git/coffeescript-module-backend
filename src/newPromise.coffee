##|
##|

co         = require 'co'
config     = require './Config'
stackTrace = require('stack-trace')

debugPromiseTimer = null

promiseCache = null

newPromiseFunction = (promiseFunction) ->

    if not config.traceEnabled
        return co promiseFunction

    ##|
    ##|  Convert the stack trace into a readable string
    trace = stackTrace.get();

    strTemp = ""
    for n in [1..4]
        if n > trace.length then continue
        if !trace[n]? then continue
        if trace[n].isNative() then continue
        filename = trace[n].getFileName()
        if !filename? then filename = ""
        filename = filename.replace "/Users/bpollack/Projects/RiverRock/", ""
        if n == 1 then filename = trace[n].getFunctionName() + "\n" + filename
        strTemp += filename + ":" + trace[n].getLineNumber() + "\n"

    ##|
    ##|  Setup an in memory tracking for each call into newPromise
    ##|  so we can see how long things take to run.
    ##|
    timer = config.timerStart("newPromise " + strTemp)

    ##|
    ##|  A timer watchdog will help us detect promises that never complete or run for
    ##|  a very long time.
    ##|
    watchdogCount = 0
    watchdog = setInterval ()=>
        console.log "Warning: watchdog timer #{++watchdogCount} on promise:", strTemp
    , 25000

    ##|
    ##|  Creating a temporary promise
    hrstart = process.hrtime()
    result  = co ()->

        tempPromise = co promiseFunction
        realResult  = yield tempPromise
        timer.log "Complete"
        clearInterval(watchdog)
        return realResult

    return result

##|
##|  Cache a promise with a given name
newPromiseCached = (cacheName, promiseFunction) =>

    if promiseCache == null then promiseCache = {}
    if !promiseCache[cacheName]?
        promiseCache[cacheName] = newPromiseFunction promiseFunction
    return promiseCache[cacheName]

module.exports        = newPromiseFunction
module.exports.cached = newPromiseCached