should = require 'should'
path   = require 'path'
config = require '../src/Config'

##|
##|  Display a simple object
config.dump "Simple object output:", { a: 10, b: 20 }

describe "Credential management", ->

    it "Should be able to get the default test credentials", ->

        ##|
        ##|  Get the credentials for a test host
        mqHost = config.getCredentials "mqHost"
        mqHost.should.equal('amqp://localhost:5672')

describe "set Credential test", ->
    it "Should be able to get info after set credential", -> 
        config.setCredentials "local", {url: "http://localhost:3000"}

        local = config.getCredentials "local"
        local.should.have.property('url', 'http://localhost:3000')

describe "Finding files", ->

    describe "Finding files in a path list", ->

        it "Should be able to find the README file", ->
            pathList = ['./', '../']
            filename = config.FindFileInPath "README.md", pathList
            should.exist(filename)
            filename.should.equal("./README.md")

        it "Should be able to find the test file", ->
            pathList = ['./', '../', './test/', './dummy/']
            filename = config.FindFileInPath "test.coffee", pathList
            should.exist(filename)
            filename.should.equal("./test/test.coffee")
        
        it "Should be Path without filename", ->
            pathList = ['./', '../']
            pathName = config.FindFileInPath "README.md", pathList, true
            pathName.should.equal(path.dirname(path.join(__dirname, '../README.md')) + '/')

            