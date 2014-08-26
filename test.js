var open = require('open');
var WsServer = require('ws').Server;

var wss = new WsServer({ port: 9333 });

wss.on('connection', function(ws) {
  ws.on('message', function(message) {
    message = JSON.parse(message);

    if (message.method == 'Console.enable') {
      ws.send(JSON.stringify({
        id: message.id,
        result: {}
      }));
      ws.send(JSON.stringify({
        "method":"Console.messageAdded",
        "params": {
          "message": {
            "source": "console-api",
            "level": "log",
            "text": "BELLA DUE",
            "timestamp": new Date().getTime(),
            "type": "log",
            "parameters": [{"type":"string","value":"BELLA DUE"}],
            "stackTrace": []
          }
        }
      }));
    } else {
      ws.send(JSON.stringify({
        id: message.id,
        error: {
          code:-32601,
          message: "'" + message.method + "' wasn't found"
        }
      }));
    }
  });
});

// open('http://127.0.0.1:8000/front_end/inspector.html?ws=127.0.0.1:9333');

