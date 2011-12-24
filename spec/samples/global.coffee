fs = require 'fs'

dict = fs.readFileSync('/usr/share/dict/words').toString().split('\n')
module.exports = dict.splice 0, 3
