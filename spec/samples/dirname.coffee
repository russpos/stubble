fs   = require 'fs'
path = require __dirname+'/dict'

dict = fs.readFileSync(path).toString().split('\n')
module.exports = dict.splice 0, 3
