http = require('http')
_ = require('lodash')
url = require('url')
events = require('events')
fs = require('fs')

IncomingMessage = http.IncomingMessage.prototype
originalMethod = IncomingMessage._addHeaderLine

IncomingMessage._addHeaderLine = (field, value) ->
  list = if @complete
    @allTrailers ||= {}
  else
    @allHeaders ||= {}

  if field in list
    list[field].push value
  else
    list[field] = value

  originalMethod.call(this, field, value)

class Server extends events.EventEmitter
  constructor: (port = 9999) ->
    @server = http.createServer()

    requestCount = 0
    @server.on 'request', (req, res) =>
      requestCount += 1
      @handleRequest(requestCount, req, res)

    @server.listen(port)

  handleRequest: (id, req, res) ->
    options = _.extend(
      {},
      url.parse(req.url),
      headers: req.headers
      method: req.method
      agent: false
    )

    remoteReq = http.request(options)
    req.pipe(remoteReq, end: true)

    data = ""
    req.on 'data', (chunk) ->
      data += chunk.toString()

    req.on 'end', =>
      @emit('requestWillBeSent', id, req, data)

    remoteReq.on 'response', (remoteRes) =>
      @handleResponse(id, res, remoteRes)

  handleResponse: (id, res, remoteRes) ->
    statusMessage = http.STATUS_CODES[remoteRes.statusCode]

    # proxy the request outside
    res.writeHeader(remoteRes.statusCode, remoteRes.allHeaders)
    remoteRes.pipe(res, end: true)

    @emit('responseReceived', id, remoteRes)

    data = ""
    remoteRes.on 'data', (chunk) ->
      data += chunk.toString()

    remoteRes.on 'end', =>
      @emit('dataReceived', id, data)

module.exports = Server

