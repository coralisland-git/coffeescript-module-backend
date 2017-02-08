# EdgeCommonConfig
> Provides general configuration, logging, and credential mangement for all Edge modules and servers.

    npm install --save ssh+git://git@gitlab.protovate.com:Edge/EdgeCommonConfig
    config = require 'edgecommonconfig'

# Common Startup

Once you include the config library several things will happen:

* Unhandled exceptions are trapped and reported automatically
* The tab title in byobu and iterm are updated with the app name see [setTitle](src/Config.coffee)
* A log file is available in a common Winston format see [getLogger](src/Config.coffee)
* Enable or disable tracing automatically

## Tracing output

The Config module looks for the --trace command line option.   If enabled, it will automatically track
the time between calls to Config.status and display a nicely formatted UI message log so you can
trace the actions of the app you are writing as well as easily optimize functions that take a while.

    config.status "MyClass::doSomething - Starting to read from database"

## Log Files

A common log file is available from Winston using

    log = config.getLogger "name"
    log.info "Something that is information"
    log.error "Something that is an error", objectToInclude

Log files are saved in /EdgeData/logs as defined by Config.logPath

## Credentials

The Config framework provides a common means of loading access credentials for
database and other services.  This is done by placing a file called *key.txt* and
*credentials.json* in a folder called ~/EdgeConfig/ on the machine.

You can generate the file using the script example in the EdgeConfig folder
for this module.

    settings = config.getCredentials "mongodb"

This will return the JSON as defined in the encrypted credentials.json file.
You can put credentials.json in your git for a project but don't store the
key.txt file in source code control.

## General helper functions

### Find if a file exists

Find a file by name given a list of one or more possible paths.  Returns null if not found

    filename = config.FindFileInPath(filename, pathList, returnPath)

returnPath parameter is false by default. 
If returnPath parameter is true then we can get the full path of file but without filename.

for example,  ../data/test.dat returns /Users/brian/data/

### Debug / dump an object

Display an object using a CoffeeScript style output with color.  Any number of arguments can be
displayed as long as the first is the "Title" or information about what you are showing.

    config.dump("Title", someObject)

### Debug / display an error or exception

Display an exception message along with color coding and (in the future) logging.   Reporting an error
does the same thing except that the error is non fatal and the exception is fatal and ends the app.

    config.reportException "What was going on", e

    config.reportError "What was going on", e



