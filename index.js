var express = require('express');
var proxy = require('http-proxy').createProxyServer();
var server = express();

server.all('/*', function(req, res) {
  console.log(req.hostname, req.headers);
  proxy.web(
    req, res,
    { target: { host: req.hostname } }
  );
});

server.listen(9000);

