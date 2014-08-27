_ = require('lodash')
ws = require('ws')
events = require('events')

DebuggingSession = require('./debugging_session')

class DebuggingServer extends events.EventEmitter
  constructor: (port = 9333) ->
    @server = new ws.Server(port: port)
    @server.on 'connection', (ws) =>

      session = new DebuggingSession(ws)
      session.on 'responseBodyRequest', =>
        @emit('responseBodyRequest', arguments...)

  sendEvent: (method, payload) ->
    message = JSON.stringify(method: method, params: payload)
    for client in @server.clients
      client.send(message)

module.exports = DebuggingServer

