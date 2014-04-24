io       = require('socket.io').listen(8800)
Q        = require('q')
Card     = require('./Model/Card')
Comment  = require('./Model/Comment')
Activity = require('./Model/Comment')

ids   = {}
io.sockets.on('connection', (socket)->
  user = {
    name:     ''
    password: ''
  }
  project  = ''
  lang     = ''

  socket.on 'setUsername', (data)->
    if user.name != ''
      socket.leave("username:#{user.name}")
    socket.join("username:#{user.name}")
    user.name = data

  socket.on 'setLang',     (data)->
    if lang != ''
      socket.leave("lang:#{data}")
    socket.join("lang:#{data}")
    lang = data

  socket.on 'setPassword', (data)->
    user.password = data

  socket.on 'setProject',  (data)->
    project = data

  socket.on 'getAll', (data)->
    Card.all(project).then( (cards)->
      cards.forEach( (card) ->
        ids[card.id] = true
        Card.get(card, lang, username)
          .then(Card.withoutDescription)
          .then(Card.getWorkflow)
          .then(
            (card)-> #Success
              socket.emit('setCard', card[0])
          )
      )
    )

  socket.on 'getDescription', (id)->
    Card.get(id, lang, username)
      .then(Card.onlyDescription)
      .then(
        (card)-> #Success
          socket.emit('setCard', card[0])
      )

  socket.on 'getActivity', (id)->
    Comment.all(id).then(
      (data)-> #Success
        data.forEach (comment)->
          socket.emit('addActivity', comment)
    )
    Activity.get(id).then(
      (data)-> #Success
        data.forEach (activity)->
          socket.emit('addActivity', activity)
    )

  socket.on 'getTitle', ->
    Card.all(project).then( (cards)->
      cards.forEach( (card) ->
        Card.get(card, lang, username)
          .then(Card.onlyTitle)
          .then(
            (card)-> #Success
              socket.emit('setCard', card[0])
          )
      )
    )

  socket.on 'getVote', ->
    Card.all(project).then( (cards)->
      cards.forEach( (card) ->
        Vote.get([card.id, lang, username])
          .then(
            (card)-> #Success
              socket.emit('setCard', card[0])
          )
      )
    )

  socket.on 'updateField', (value, fn) ->
    Card.updateField(value, user).then(
      (data)-> #Success
        fn("Done:#{data.response}")
        Card.get(value.id, lang, username)
          .then(
            (data)-> #Success
              data = data[0]
              result = {
                id: data.id
              }
              result[value.element] = data[value.element]
              io.sockets.in("lang:#{lang}").emit('setCard', result)
            ,(err)-> #Error
              console.log err
          )
      ,(err)-> #Error
        fn("Error:#{ JSON.stringify(err.response) }")
    )

  socket.on 'newComment', (data, fn)->
    Comment.create(data, user).then(
      (data)-> #Success
        fn("Done:#{data.response}")
        db.get(data.id, (err, res)->
          if err
            console.log err
          else
            socket.emit('addActivity', res)
        )
      ,(err)-> #Error
        fn("Error:#{err.response}")
    )

  socket.on 'newCard', (data, fn)->
    Card.create(data, user, ids).then(
      (data)-> #Success
        fn("Done:#{data.response}")
        getCard(data.id, lang, username)
          .then(withoutDescription)
          .then(Vote.get)
          .then(getWorkflow)
          .then(
            (data)-> #Success
              io.sockets.emit('addCard', data[0])
          )
      ,(err)-> #Error
        fn("Error:#{err.response}")
    )

  socket.on 'setVote', (data, fn)->
    promise = null
    if not data.check
      promise = Vote.set(data, user)
    else
      promise = Vote.unset(data, user)

    promise.then(
      (res)-> #Succes
        fn("Done:#{res.response}")
        Vote.get([data.id, lang, username])
          .then(
            (data)->
              data = data[0]
              io.socket.in("username:#{username}").emit('setCard', data)
              delete data.vote
              socket.broadcast.emit('setCard', data)
            ,(err)->
              console.log err
          )
      ,(err)-> #Error
        fn("Error:#{JSON.stringify(err.response)}")
    )
)

process.on 'uncaughtException', (err) ->
  console.error('An uncaughtException was found, the program will end.')
  console.error(err)
  process.exit(1)
