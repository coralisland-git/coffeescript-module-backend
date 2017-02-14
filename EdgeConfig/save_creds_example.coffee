##|
##|  This file generates a very simple encrypted configuration for credentials to be stored on a server
##|  Two versions of the file are generated at the same time, one is for production and one is for testing.
##|
##|  This demo code generates the same file
##|

encrypter      = require('object-encrypter');
jsonfile       = require 'jsonfile'
fs             = require 'fs'
ReadPreference = require('mongodb').ReadPreference

access_data =

    ##|
    ##| Edge primary mongo Database

    MongoDB:
        url: "mongodb://sa:edge5516789@dev1.protovate.com:27017/admin?readPreference=primary"
        options:
            db:
                numberOfRetries : 5
                native_parser   : true
            server:
                auto_reconnect : true
                poolSize       : 8
                strategy       : "ping"
                socketOptions  :
                    socketTimeoutMS: 600000
                    connectTimeoutMS: 600000

    redisReadHost         : "redis://:1d1b846a8b9c46e9e1562733cd483f19@dev1.protovate.com"
    redisHost             : "redis://:1d1b846a8b9c46e9e1562733cd483f19@dev1.protovate.com"

    mqHost                : "amqp://edge:Edge000199@dev1.protovate.com:5672"
    mqAdmin               : "http://sa:sa0000001@dev1.protovate.com:15672"

    elasticsearch :
        type: "es"
        url : "http://sa:sa0000001@dev1.protovate.com:9201/"

##|
##|  Dev settings change some values from the base config and create a new file.
##|
access_data_dev =

    MongoDB:

        url: "mongodb://127.0.0.1:27017/admin"
        options:
            db:
                numberOfRetries: 5
                native_parser:   true
                slaveOk:         true
            server:
                auto_reconnect : true
                poolSize       : 8
                socketOptions  :
                    socketTimeoutMS: 600000
                    connectTimeoutMS: 600000

    Southcrest:
        client: 'mysql'
        connection:
            host     : '127.0.0.1'
            port     : 3307
            user     : 'southcrest'
            password : 'south999abc'
            database : 'southcrest'

    redisHost     : "redis://127.0.0.1:6379"
    redisReadHost : "redis://127.0.0.1:6379"
    mqHost        : "amqp://127.0.0.1:5672"

##|
##|  Read the key file
key    = fs.readFileSync "key.txt"
key    = key.toString()
engine = encrypter key

##|
##|  Save the credentials to a file
hex = engine.encrypt access_data
jsonfile.writeFileSync "credentials.json", hex
console.log "Saved credentials.json"

for varName, value of access_data_dev
    access_data[varName] = value

hex = engine.encrypt access_data
jsonfile.writeFileSync "credentials_dev.json", hex
console.log "Saved credentials_dev.json"

