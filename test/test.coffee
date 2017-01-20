should = require 'should'
config = require '../src/Config'

##|
##|  Display a simple object
config.dump "Simple object output:", { a: 10, b: 20 }

describe "Credential management", ->

    it "Should be able to get the default test credentials", ->

        ##|
        ##|  Get the credentials for a test host
        mqHost = config.getCredentials "mqHost"
        mqHost.should.equal('amqp://127.0.0.1:5672')