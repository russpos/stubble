fs   = require('fs');
path = require('path');

dict = fs.readFileSync(path.join('/usr/share', 'dict/words')).toString().split('\n');
module.exports = dict.splice(0, 3);
