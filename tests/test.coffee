config = require '../src/Config'

config.dump "Simple object output:", { a: 10, b: 20 }

mqHost = config.getCredentials "mqHost"
config.dump "mqHost Credentials:", mqHost