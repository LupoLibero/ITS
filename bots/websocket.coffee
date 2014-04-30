io        = require('socket.io').listen(8800)
db        = require('./db')()
http      = require('http')
httpProxy = require('http-proxy')
Q         = require('q')
Activity  = require('./Model/Activity')
Card      = require('./Model/Card')
Comment   = require('./Model/Comment')
Local     = require('./Model/Local')
Vote      = require('./Model/Vote')
ids       = {}

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

multiRoomFilter = (rooms, event, data)->
  room  = rooms.pop()
  for socket in io.sockets.clients(room)
    found = true
    for room in rooms
      clients = socket.manager.rooms["/#{room}"] ? []
      unless socket.id in clients
        found = false
        break
    if found
      socket.emit(event, data)

db.changes({
  since: "now"
  include_docs: true
}).on('change', (change)->
  doc = change.doc
  rev = parseInt(doc._rev)
  switch doc.type
    when "vote"
      Vote.get([doc.voted_doc_id, '', '']).then(
        (data)-> #Success
          delete data[0].vote
          io.sockets.emit('setCard', data[0])
          io.sockets.in("username:#{doc.voter}").emit('setCard', {
            id:   data[0].id
            vote: (if change.deleted then '' else doc.voter)
          })
        ,(err)-> #Error
          console.log err
      )
    when "card"
      if rev == 1 #NewCard
        ids[doc.id] = true
        Card.get([doc, doc.init_lang, ''])
          .then(Card.translate)
          .then(Card.withoutDescription)
          .then(Card.getWorkflow)
          .then(
            (data)-> #Success
              card = data[0]
              io.sockets.emit('setCard', data[0])
            ,(err)-> #Error
              console.log err
          )
      else
        lastActivity     = doc.activity[doc.activity.length-1]
        field            = lastActivity.element
        lastActivity._id = doc._id
        delete lastActivity.content
        delete lastActivity._rev
        io.sockets.in("show:#{doc._id}").emit('addActivity', lastActivity)
        for lang, content of doc[field]
          content.lang  = lang
          result        = {}
          result.id     = doc.id
          result._rev   = doc._rev
          result[field] = content
          if field == 'title'
            io.sockets.in("lang:#{lang}").emit('setCard', result)
          else if field == 'description'
            multiRoomFilter(["lang:#{lang}", "show:#{doc._id}"], 'setCard', result)
    when "comment"
      io.sockets.in("show:#{doc.parent_id}").emit('addActivity', doc)
)

io.sockets.on('connection', (socket)->
  user = {
    name:   ''
    pass:   ''
    cookie: socket.handshake.headers.cookie
  }
  project  = ''
  lang     = ''
  show     = ''

  socket.on 'setUsername', (req, fn)->
    socket.leave("username:#{user.name}")
    socket.join("username:#{req}")
    user.name = req

  socket.on 'setLang', (req, fn)->
    socket.leave("lang:#{lang}")
    socket.join("lang:#{req}")
    lang = req

  socket.on 'setPassword', (req, fn)->
    user.pass = req

  socket.on 'setShow', (req, fn)->
    socket.leave("show:card:#{show}")
    socket.join("show:card:#{req}")
    show = req

  socket.on 'setProject',  (req, fn)->
    project = req

  socket.on 'getAll', (req, fn)->
    Card.all(project).then (cards)->
      cards.forEach (card) ->
        ids[card.id] = true
        Card.translate([card, lang, user])
          .then(Card.withoutDescription)
          .then(Card.getWorkflow)
          .then(
            (data)-> #Success
              socket.emit('setCard', data[0])
          )

  socket.on 'getDescription', (req, fn)->
    Card.get([req, lang, user])
      .then(Card.translate)
      .then(Card.onlyDescription)
      .then(
        (data)-> #Success
          socket.emit('setCard', data[0])
      )

  socket.on 'getActivity', (req, fn)->
    id = "card:#{req}"
    Comment.all(id)
      .then(
        (data)-> #Success
          data.forEach (comment)->
            socket.emit('addActivity', comment)
      )
    Activity.all(id)
      .then(
        (data)-> #Success
          data.forEach (activity)->
            socket.emit('addActivity', activity)
      )

  socket.on 'getTitle', (req, fn)->
    Card.all(project).then (cards)->
      cards.forEach  (card) ->
        Card.translate([card, lang, user])
          .then(Card.onlyTitle)
          .then(
            (card)-> #Success
              socket.emit('setCard', card[0])
          )

  socket.on 'getVote', (req, fn)->
    for id, value of ids
      Vote.get(["card:#{id}", lang, user])
        .then(
          (card)-> #Success
            socket.emit('setCard', card[0])
        )

  socket.on 'updateField', (req, fn) ->
    Card.updateField(req, user).then(
      (data)-> #Success
        fn("Done:#{data.response}")
      ,(err)-> #Error
        fn("Error:#{err}")
    )

  socket.on 'newComment', (req, fn)->
    Comment.create(req, user).then(
      (data)-> #Success
        fn("Done:#{data.response}")
      ,(err)-> #Error
        fn("Error:#{err}")
    )

  socket.on 'newCard', (req, fn)->
    Card.create(req, user, ids).then(
      (data)-> #Success
        fn("Done:#{data.response}")
      ,(err)-> #Error
        fn("Error:#{err}")
    )

  socket.on 'setVote', (req, fn)->
    promise = null
    if not req.check
      promise = Vote.set(req, user)
    else
      promise = Vote.unset(req, user)

    promise.then(
      (data)-> #Succes
        fn("Done:#{data.response}")
      ,(err)-> #Error
        fn("Error:#{err}")
    )

  socket.on 'setTranslation', (data, fn)->
    Local.set(data.key, data.text, lang, user).then(
      (data)-> #Success
        fn("Done:#{data.response}")
      ,(err)-> #Error
        fn("Error:#{err}")
    )
)

process.on 'uncaughtException', (err) ->
  console.error('An uncaughtException was found, the program will end.')
  console.error(err)
  process.exit(1)
