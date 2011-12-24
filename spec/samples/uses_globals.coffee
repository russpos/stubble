b = new Buffer('/usr/share/dict/words')
fs = require 'fs'

error = -> throw 'This should have been cancelled'
close = -> fs.closeSync()

timeout = setTimeout error, 10
setTimeout close, 1
clearTimeout timeout

interval = setInterval error, 10
clearInterval interval

fs.readFileSync b.toString()

process.nextTick -> fs.writeFileSync '/my/path', 'data'
module.exports = process.env.PASS_THE_ENV.split ","
