fs = require 'fs'
fs.readFileSync '/usr/share/dict/words'

module.exports = require './words'
