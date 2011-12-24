fs = require 'fs'
path = require '../below'
module.exports = fs.readFileSync(path).toString().split('\n').splice(0, 3)
