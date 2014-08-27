http = require('http')
_ = require('lodash')
url = require('url')
events = require('events')
zlib = require('zlib')
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
      id = "proxo." + requestCount
      @handleRequest(id, req, res)

    @server.listen(port)

  handleRequest: (id, req, res) ->
    options = _.extend(
      {},
      url.parse(req.url),
      headers: req.headers
      method: req.method
    )

    remoteReq = http.request(options)

    data = ""
    req.on 'data', (chunk) ->
      data += chunk.toString()

    req.on 'end', =>
      @emit('requestWillBeSent', id, req, data)

    remoteReq.on 'response', (remoteRes) =>
      @handleResponse(id, req, res, remoteRes)

    req.pipe(remoteReq)

  handleResponse: (id, req, res, remoteRes) ->
    remoteRes.statusMessage = http.STATUS_CODES[remoteRes.statusCode]

    contentType = remoteRes.headers['content-type']

    if contentType
      remoteRes.mimeType = mime = contentType.replace(/;.*$/, '')

      remoteRes.resourceType = if mime.match(/^image/)
        "Image"
      else if mime == 'text/css'
        "Stylesheet"
      else if mime.match(/javascript/)
        "Script"
      else if mime == 'text/html' || mime.match(/json/) || mime.match(/xml/)
        "Document"
      else
        "Other"
    else
      remoteRes.resourceType = "Other"

    remoteRes.pipe(res)
    res.writeHead(remoteRes.statusCode, remoteRes.allHeaders)

    @emit('responseReceived', id, req, remoteRes)

    contentEncoding = remoteRes.headers['content-encoding']
    bodyReader = if contentEncoding == 'gzip'
      remoteRes.pipe(zlib.createGunzip())
    else if contentEncoding == 'deflate'
      remoteRes.pipe(zlib.createInflate())
    else
      remoteRes

    bodyChunks = []
    bodyReader.on 'data', (chunk) ->
      bodyChunks.push(chunk)

    bodyReader.on 'end', =>
      result = Buffer.concat(bodyChunks)
      data = if remoteRes.resourceType == 'Image' || remoteRes.resourceType == 'Other'
        {
          body: result.toString('base64'),
          base64Encoded: true,
          length: result.length
        }
      else
        {
          body: result.toString(),
          base64Encoded: false,
          length: result.length
        }

      @emit('dataReceived', id, data)

module.exports = Server

