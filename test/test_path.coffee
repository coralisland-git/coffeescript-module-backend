#!/usr/bin/env coffee

config = require '../src/Config'

test = config.getDataPath "sample/something/else"
console.log "Got Path:", test

test = config.getDataPath "sample/something/else/file.txt"
console.log "Got File:", test

