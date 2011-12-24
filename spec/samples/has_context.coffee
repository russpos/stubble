fs = require 'fs'

path = new global.Buffer '/usr/share/dict/words'
fs.readFileSync path.toString()

module.exports = ['a', 'b', 'c']
