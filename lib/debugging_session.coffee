events = require('events')

METHOD_NOT_FOUND_ERROR = -32601

CANNED_RESPONSES = {
  'Network.canClearBrowserCache': { result: false },
  'Network.canClearBrowserCookies': { result: false },
  'Network.enable': {},
  'Page.canScreencast': { result: false},
  'Page.enable': {}
}

class DebuggingSession extends events.EventEmitter
  constructor: (@ws) ->
    @ws.on 'message', (message) => @handleCommand(message)

  handleCommand: (command) ->
    command = JSON.parse(command)

    if response = CANNED_RESPONSES[command.method]
      @replyToCommand(command, response)
    else if command.method == 'Network.getResponseBody'
      @emit('responseBodyRequest', this, command, command.params.requestId)
    else
      @replyToCommand(
        command,
        error:
          code: METHOD_NOT_FOUND_ERROR,
          message: "'#{command.method}' wasn't found"
      )

  replyToCommand: (command, payload) ->
    @ws.send(JSON.stringify(id: command.id, result: payload))

module.exports = DebuggingSession

