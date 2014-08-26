var WebSocketServer = require('ws').Server;
var wss = new WebSocketServer({port: 9333});

wss.on('connection', function(ws) {
  console.log("CIAO");
  ws.on('message', function(message) {
    console.log('received: %s', message);
  });

  var contextCreated = {
    "method":"Runtime.executionContextCreated",
    "params": {
      "context": {
        "id":48,
        "isPageContext":true,
        "frameId":"7907.24"
      }
    }
  };

  var messageAdded = {
    "method":"Console.messageAdded",
    "params": {
      "message": {
        "source":"console-api",
        "level":"log",
        "text":"BELLA DUE",
        "timestamp":new Date().getTime(),
        "type":"log",
        "parameters":[{"type":"string","value":"BELLA DUE"}],
        "stackTrace":[]
      }
    }
  };

  setTimeout(function() { 
    ws.send(JSON.stringify(contextCreated)); 
    ws.send(JSON.stringify(messageAdded)); 
    console.log("Sent"); 
  }, 5000);
});

