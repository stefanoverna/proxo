_ = require('lodash')
WsServer = require('ws').Server
DebuggingSession = require('./debugging_session')

class DebuggingServer
  constructor: (options = {}) ->
    options = _.defaults(options, port: 9333)
    @server = new WsServer(options)
    @sessions = []
    @server.on 'connection', (ws) ->
      new DebuggingSession(ws)

  sendEvent: (name, payload) ->
    @server.broadcast(JSON.stringify(method: method, params: payload))

module.exports = DebuggingServer

