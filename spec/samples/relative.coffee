fs   = require 'fs'
path = require './dict'

dict = fs.readFileSync(path).toString().split('\n')
module.exports = dict.splice 0, 3
