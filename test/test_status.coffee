#!/usr/local/bin/coffee

config = require '../src/Config'

str = "Testing string"
config.status "Testing string=", str

str = 123
config.status "Testing number=", str

str = { name: "Brian Pollack", age: 41 }
config.status "Testing simple object:", str

str = [ "A", "B", "C" ]
config.status "Testing simple array:", str