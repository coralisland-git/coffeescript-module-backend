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
        url: "mongodb://sa:EG9VtP9fP9QpQyS5@dev1.protovate.com:27017/admin?readPreference=primary"
        options:
            poolSize        : 16
            socketTimeoutMS : 600000
            connectTimeoutMS: 600000

    redisReadHost         : "redis://:1d1b846a8b9c46e9e1562733cd483f19@dev1.protovate.com"
    redisHost             : "redis://:1d1b846a8b9c46e9e1562733cd483f19@dev1.protovate.com"

    mqHost                : "amqp://edge:Edge000199@dev1.protovate.com:5672"
    mqAdmin               : "http://sa:sa0000001@dev1.protovate.com:15672"

    elasticsearch :
        type: "es"
        url : "http://sa:sa0000001@dev1.protovate.com:9201/"

    ApiServers:[
        'http://localhost:8001',
        'http://localhost:8001'
    ]
    ProxyList:[
        'http://localhost:8081',
        'http://localhost:8082',
        'http://localhost:8083',
        'http://localhost:8084',
        'http://localhost:8085',
    ]

    influxdb:
        type: "influxdb"
        host: "dev1.protovate.com"
        username: "admin"
        password: "5Ssb1ARQWo"

##|
##|  Dev settings change some values from the base config and create a new file.
##|
access_data_dev =

    MongoDB:

        url: "mongodb://127.0.0.1:27017/admin"
        options:
            poolSize        : 8
            socketTimeoutMS : 600000
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
    ApiServers:[
        'http://localhost:8001',
        'http://localhost:8001'
    ]
    ProxyList:[
        'http://localhost:8081',
        'http://localhost:8082',
        'http://localhost:8083',
        'http://localhost:8084',
        'http://localhost:8085',
    ]

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

