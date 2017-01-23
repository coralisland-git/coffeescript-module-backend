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
        url: "mongodb://user:password@localhost:27017/admin?replicaSet=rr0"
        options:
            db:
                numberOfRetries : 5
                native_parser   : true
                readPreference  : ReadPreference.NEAREST
                slaveOk         : true
            replSet:
                connectWithNoPrimary : true
                slaveOk              : true
                replicaSet           : "rr0"
                poolSize             : 4
                strategy             : "ping"
                readPreference       : ReadPreference.NEAREST
                socketOptions        :
                    socketTimeoutMS: 60000
                    connectTimeoutMS: 60000
            server:
                auto_reconnect : true
                poolSize       : 8
                slaveOk        : true
                strategy       : "ping"
                socketOptions  :
                    socketTimeoutMS: 600000
                    connectTimeoutMS: 600000

    redisReadHost         : "redis://@localhost"
    redisHost             : "redis://@localhost"

    mqHost                : "amqp://localhost:5672"
    mqAdmin               : "http://sa:g1s00000j9@localhost:15674"

    "Watson-ToneAnalyzer" :
        "url"             : "https://gateway.watsonplatform.net/tone-analyzer/api"
        "password"        : "xxxxxxxxxx"
        "username"        : "yyyyyyyyyy"

    RedshiftPG :
        user              : "sa"
        password          : "xxxxxxxxxx"
        database          : "prop"
        host              : "rrv3.cnpns8nqpiu3.us-east-1.redshift.amazonaws.com"
        port              : 5439
        max               : 4
        idleTimeoutMillis : 30000

    elasticsearch :
        accessKeyId       : "AKIAIGXHBXLAEA4PX7HA"
        secretAccessKey   : "xxxxxxxxxxxxxxxxxxxx"
        service           : 'es'
        region            : "us-east-1"
        host              : "search-rrportal-a7u25qwkomjxflicafylg32oeu.us-east-1.es.amazonaws.com"

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

    RedshiftPG:
        user              : ""
        password          : ""
        database          : ""
        host              : "127.0.0.1"
        port              : 5439
        max               : 4
        idleTimeoutMillis : 30000

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

