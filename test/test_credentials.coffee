should = require 'should'
config = require '../src/Config'

mqHost = config.getCredentials "mqHost"

if mqHost == "amqp://edge:Edge000199@dev1.protovate.com:5672"
	console.log "GETTING CREDENTIAL is successful"
else
	console.log "GETTING CREDENTIAL is failed"