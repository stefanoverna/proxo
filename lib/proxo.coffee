DebuggingServer = require('./debugging_server')
DevtoolsServer = require('./devtools_server')
ProxyServer = require('./proxy_server')

debuggingServer = new DebuggingServer()
devToolsServer = new DevtoolsServer()
proxyServer = new ProxyServer()

proxyServer.on 'requestWillBeSent', (id, request, body) ->
  console.log id, request.url, body

  # debuggingServer.sendEvent(
  #   'Network.requestWillBeSent',
  #   requestId: reqId,
  #   loaderId: "LOADER",
  #   documentURL: request.originalUrl,
  #   request:
  #     url: request.originalUrl,
  #     method: request.method,
  #     headers: req.allHeaders,
  #     postData: ""
  #   timestamp: timestamp,
  #   initiator:
  #     type: "other"
  # )

proxyServer.on 'responseReceived', (id, response) ->
  console.log 'responseReceived', id

  # debuggingServer.sendEvent(
  #   'Network.responseReceived',
  #   requestId: req.reqId,
  #   loaderId: "LOADER",
  #   timestamp: timestamp,
  #   type: "Document",
  #   response:
  #     url: url,
  #     status: res.statusCode,
  #     statusText: "",
  #     headers: proxyRes.headers,
  #     mimeType: "text/html",
  #     connectionReused: false,
  #     connectionId: 5392,
  #     encodedDataLength: -1,
  #     fromDiskCache: false,
  #     timing:
  #       requestTime: timestamp,
  #       connectStart: 65.06999999874097,
  #       connectEnd: 256.3419999987673,
  #       proxyStart: -1,
  #       proxyEnd: -1,
  #       dnsStart: 0.7949999999254942,
  #       dnsEnd: 65.06999999874097,
  #       sslStart: -1,
  #       sslEnd: -1,
  #       sendStart: 256.4640000000509,
  #       sendEnd: 256.59300000006624,
  #       receiveHeadersEnd: 467.6789999994071
  #     requestHeaders: req.headers,
  #     remoteIPAddress: "66.147.244.191",
  #     remotePort: 80
  # )

proxyServer.on 'dataReceived', (id, data) ->
  console.log 'dataReceived', id

  # debuggingServer.sendEvent(
  #   "Network.dataReceived",
  #   requestId: id,
  #   timestamp: timestamp,
  #   dataLength: 5200,
  #   encodedDataLength: 162
  # )

