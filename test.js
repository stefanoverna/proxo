var open = require('open');
var WsServer = require('ws').Server;
var express = require('express');
var urlUtils = require('url');
var http = require('http');

var wss = new WsServer({ port: 9333 });

var responseDictionary = {
  'Network.canClearBrowserCache': {"result":false},
  'Network.canClearBrowserCookies': {"result":false},
  'Network.enable': {},
  'Page.canScreencast': {"result":false},
  'Page.enable': {}
}

var socket = null;

var send = function(payload) {
  if (socket) {
    socket.send(JSON.stringify(payload));
  }
}

var sendReply = function(id, result) {
  send({ id: id, result: result });
};

var sendEvent = function(method, params) {
  send({ method: method, params: params });
}

wss.on('connection', function(ws) {
  socket = ws;

  ws.on('message', function(message) {
    message = JSON.parse(message);
    method = message.method;
    if (response = responseDictionary[method]) {
      sendReply(message.id, response);
    } else {
      sendReply(message.id, { error: { code: -32601, message: "'" + method + "' wasn't found" } });
    }
  });
});

var requestsDB = [];

proxy.on('start', function(req, res, target) {
  console.log("start");
});

proxy.on('proxyReq', function(proxyReq, req, res, options) {
  console.log("proxyReq");
});

proxy.on('error', function(err, req, res, target) {
  console.log("error");
});

proxy.on('end', function(req, res, proxyRes) {
  console.log("end");
});

proxy.on('proxyRes', function(proxyRes, req, res) {
  var timestamp = new Date().getTime() / 1000;
  var url = req.originalUrl;
  console.log("proxyRes", req.reqId);

  sendEvent(
    "Network.responseReceived",
    {
      requestId: req.reqId,
      loaderId:"LOADER",
      timestamp: timestamp + 0.5,
      type:"Document",
      response:{
        url:url,
        status:res.statusCode,
        statusText:"",
        headers:proxyRes.headers,
        mimeType:"text/html",
        connectionReused:false,
        connectionId:5392,
        encodedDataLength:-1,
        fromDiskCache:false,
        timing:{
          requestTime:timestamp,
          connectStart:65.06999999874097,
          connectEnd:256.3419999987673,
          proxyStart:-1,
          proxyEnd:-1,
          dnsStart:0.7949999999254942,
          dnsEnd:65.06999999874097,
          sslStart:-1,
          sslEnd:-1,
          sendStart:256.4640000000509,
          sendEnd:256.59300000006624,
          receiveHeadersEnd:467.6789999994071
        },
        requestHeaders:req.headers,
        remoteIPAddress:"66.147.244.191",
        remotePort:80
      }
    }
  );

  sendEvent(
    "Network.dataReceived",
    {
      requestId: req.reqId,
      timestamp: timestamp,
      dataLength: 5200,
      encodedDataLength: 162
    }
  );
});

var proxyServer = express();
proxyServer.all('/*', function(req, res) {

  var matches = req.headers.host.match(/^([^:]+):?(.*)$/)
  var target = { host: matches[1] };
  if (matches[2]) { target.port = matches[2]; }

  var url = req.originalUrl;
  var reqId = "req." + (requestsDB.length + 1);
  var timestamp = new Date().getTime() / 1000;

  req.reqId = reqId;

  console.log(url, reqId);

  proxy.web(req, res, { target: target });
  requestsDB.push(url);

  sendEvent(
    "Network.requestWillBeSent",
    {
      requestId: reqId,
      loaderId: "LOADER",
      documentURL: url,
      request: {
        url:url,
        method:req.method,
        headers:req.headers,
        postData: ""
      },
      timestamp: timestamp,
      initiator:{"type":"other"}
    }
  );

});
proxyServer.listen(8383);

open('http://127.0.0.1:3000/front_end/inspector.html?ws=127.0.0.1:9333');

// var http = require('http');

// http.createServer(onRequest).listen(3000);

// function onRequest(client_req, client_res) {
//   console.log('serve: ' + client_req.url);

//   var options = {
//     hostname: 'www.google.com',
//     port: 80,
//     path: client_req.url,
//     method: 'GET'
//   };

//   var proxy = http.request(options, function (res) {
//     res.pipe(client_res, {
//       end: true
//     });
//   });

//   client_req.pipe(proxy, {
//     end: true
//   });
// }

