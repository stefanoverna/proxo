express = require('express')

class Server
  constructor: (port = 3000) ->
    @server = express()
    @server.use(express.static(__dirname + '/../devtools'))
    @server.listen(port)

module.exports = Server

