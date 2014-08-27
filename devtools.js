var express = require('express');
var devtools = express();
devtools.use(express.static(__dirname + '/devtools'));
devtools.listen(3000);

