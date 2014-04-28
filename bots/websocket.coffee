io       = require('socket.io').listen(8800)
Q        = require('q')
Activity = require('./Model/Activity')
Card     = require('./Model/Card')
Comment  = require('./Model/Comment')
Local    = require('./Model/Local')
Vote     = require('./Model/Vote')

ids   = {}
io.sockets.on('connection', (socket)->
  user = {
    name:   ''
    pass:   ''
    cookie: socket.handshake.headers.cookie
  }
  project  = ''
  lang     = ''

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
      Vote.get([id, lang, user])
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
