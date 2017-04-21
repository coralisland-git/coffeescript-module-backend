fs     = require 'fs'
config = require '../src/Config'

##|
##|  Simple test case should print an exception within this file

log = config.getLogger("test2");
log.error "Internal error"

str1 = "Hello"
number1 = 123

testFunction = ()->
    return new Promise (resolve, reject) => 
        str1.callFunctionThatDoesntExist()
        resolve(false)

testFunction()
number2 = 123
number3 = 123