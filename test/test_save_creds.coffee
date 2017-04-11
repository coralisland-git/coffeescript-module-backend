argv = require("yargs")
should = require 'should'
{ EdgeSaveCreds } = require '../src/edge_save_creds' 

describe 'Save creds', ->
	it 'should have default input and output', ->
		argv.i = "4"
		argv.o = "5"

		describe argv.i + " | " + argv.o, -> 
			c = EdgeSaveCreds argv.i, argv.o
			console.log c
			# creds.read(argv.i, argv.o)
