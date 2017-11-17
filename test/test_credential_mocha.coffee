should = require 'should'
config = require '../src/Config'

describe "Credential management", ->

    it "Should be able to get the default test credentials", ->

        ##|
        ##|  Get the credentials for a test host
        mqHost = config.getCredentials "mqHost"
        mqHost.should.equal('amqp://edge:Edge000199@dev1.protovate.com:5672')