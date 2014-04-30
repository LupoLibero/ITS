http      = require('http')
httpProxy = require('http-proxy')

socketio = new httpProxy.createProxyServer({
  target: {
    host: '127.0.0.1'
    port:  8800
  }
})
couch = new httpProxy.createProxyServer({
  target: {
    host: '127.0.0.1'
    port:  5984
  }
})

proxyServer = http.createServer (req, res)->
  base = req.url.split('/')[1]
  if base == 'socket.io'
    socketio.web(req, res)
  else
    couch.web(req, res)

proxyServer.on 'upgrade', (req, socket, head) ->
  setTimeout( ->
    socketio.ws(req, socket, head)
  ,1000)

proxyServer.listen(8000)
