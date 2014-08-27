DebuggingServer = require('./debugging_server')
ProxyServer = require('./proxy_server')
DevtoolsServer = require('./devtools_server')
utf8 = require('utf8')

debuggingServer = new DebuggingServer(9333)
proxyServer = new ProxyServer(9999)
devtoolsServer = new DevtoolsServer(3000)

timestamp = ->
  new Date().getTime() / 1000

requestTimings = {}
requestBodies = {}

debuggingServer.on 'responseBodyRequest', (connection, command, id) ->
  connection.replyToCommand(command, requestBodies[id])

proxyServer.on 'requestWillBeSent', (id, request, body) ->
  time = timestamp()
  requestTimings[id] = time

  debuggingServer.sendEvent(
    'Network.requestWillBeSent',
    requestId: id,
    loaderId: "LOADER",
    documentURL: request.url,
    request:
      url: request.url,
      method: request.method,
      headers: request.allHeaders,
      postData: body
    timestamp: time,
    initiator:
      type: "other"
  )

proxyServer.on 'responseReceived', (id, request, response) ->
  time = timestamp()

  debuggingServer.sendEvent(
    'Network.responseReceived',
    requestId: id,
    loaderId: "LOADER",
    timestamp: time,
    type: response.resourceType,
    response:
      url: request.url,
      status: response.statusCode,
      statusText: response.statusMessage,
      headers: response.allHeaders,
      requestHeaders: request.allHeaders,
      mimeType: response.mimeType,
      connectionReused: false,
      connectionId: 5392,
      encodedDataLength: -1,
      fromDiskCache: false,
      timing:
        proxyStart: -1,
        proxyEnd: -1,
        sslStart: -1,
        sslEnd: -1,
        requestTime: requestTimings[id],
        dnsStart: 0,
        dnsEnd: 0,
        connectStart: 0,
        connectEnd: 0,
        sendStart: 0,
        sendEnd: 0,
        receiveHeadersEnd: parseInt((time - requestTimings[id]) * 1000)
  )

proxyServer.on 'dataReceived', (id, data) ->
  time = timestamp()

  requestBodies[id] = data

  debuggingServer.sendEvent(
    'Network.dataReceived',
    requestId: id,
    timestamp: time,
    dataLength: data.length,
    encodedDataLength: data.length
  )

  debuggingServer.sendEvent(
    'Network.loadingFinished',
    requestId: id,
    timestamp: time
  )

