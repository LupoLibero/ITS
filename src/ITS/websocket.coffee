host     = '127.0.0.1'
port     = 5984
database = 'lupolibero'

io      = require('socket.io').listen(8800)
http    = require('http')
Q       = require('q')
cradle  = require('cradle')
db      = new(cradle.Connection)("http://#{host}", port, { cache: false }).database(database)
view    = Q.nbind(db.view, db)
changes = Q.nbind(db.changes, db)

update = (doc, id = '', data = {}, headers = {}) ->
  defer      = Q.defer()
  design     = doc.split('/')[0]
  updateName = doc.split('/')[1]
  method     = (if id is '' then 'POST' else 'PUT')
  if headers.password? and headers.password != ''
    console.log headers.user
    console.log headers.password
    basic = new Buffer("#{headers.user}:#{headers.password}").toString('base64')
    headers = {
      "Authorization": "Basic #{basic}"
    }

  req = http.request({
    hostname:  host
    method:    method
    port:      port
    path:      "/#{database}/_design/#{design}/_update/#{updateName}/#{id}"
    headers:   headers
  }, (res)->
    res.setEncoding('utf8')
    res.on('data', (body)->
      try
        body = JSON.parse(body)

      data = {
        response: body
        status:   res.statusCode
      }

      if res.headers.hasOwnProperty('x-couch-update-newrev')
        data.rev = res.headers['x-couch-update-newrev']
      if res.headers.hasOwnProperty('x-couch-id')
        data.id  = res.headers['x-couch-id']

      if res.statusCode.toString()[0] > 3
        defer.reject(data)
      else
        defer.resolve(data)
    )
  )

  req.write(JSON.stringify(data))
  req.end()
  return defer.promise


getRandomChar = ->
  chars = "1234567890abcdefghijklmnopqrstuvwxyz"
  num   = Math.floor(Math.random() * chars.length)
  return chars.charAt(num)

createID = (ids, num=3, count=1) ->
  id = ''
  if count == 3
    num++
    count=1

  for i in [num..1]
    id += getRandomChar()

  if ids.hasOwnProperty(id)
    count++
    return createID(ids, num, count)
  return id

getCards = (project)->
  return view('its/card_all')

getCard = (card, lang, username)->
  defer = Q.defer()

  if typeof card == 'string'
    view('its/card_all', {
      key: card
    }).then(
      (data)->
        data = data[0].value
        getCard(data, lang, username).then(
          (data)-> #Success
            defer.resolve(data)
          ,(err)-> #Error
            defer.reject(err)
        )
      ,(err)->
        defer.reject(err)
    )
  else if typeof card == 'object'
    card.num = card.id.split('.')[1]
    if card.title.hasOwnProperty(lang)
      card.title      = card.title[lang]
      card.title.lang = lang
    else
      card.title      = card.title[card.init_lang]
      card.title.lang = card.init_lang

    if card.description.hasOwnProperty(lang)
      card.description      = card.description[lang]
      card.description.lang = lang
    else
      card.description      = card.description[card.init_lang]
      card.description.lang = card.init_lang

    delete card.init_lang
    delete card.type

    defer.resolve([card, lang, username])
  return defer.promise

withoutDescription = (result) ->
  card     = result[0]
  lang     = result[1]
  username = result[2]
  defer = Q.defer()
  delete card.description
  defer.resolve([card, lang, username])
  return defer.promise

onlyDescription = (result) ->
  card     = result[0]
  lang     = result[1]
  username = result[2]
  defer    = Q.defer()
  card = {
    id:           card.id
    lang:         card.lang
    description:  card.description
  }
  defer.resolve([card, lang, username])
  return defer.promise

onlyTitle = (result) ->
  card     = result[0]
  lang     = result[1]
  username = result[2]
  defer    = Q.defer()
  card = {
    id:     card.id
    lang:   card.lang
    title:  card.title
  }
  defer.resolve([card, lang, username])
  return defer.promise

getVote = (result) ->
  card     = result[0]
  lang     = result[1]
  username = result[2]

  if typeof card != 'object'
    card = {
      id: card
    }

  defer = Q.defer()
  view('its/vote_all', {
    key: "card:#{card.id}"
  }).then(
    (data)-> #Success
      result = {}
      for row in data
        for user, vote of row.value
          result[user] = vote

      card.rank = Object.keys(result).length
      card.vote = {}
      if result.hasOwnProperty(username)
        card.vote = username

      defer.resolve([card, lang, username])
    ,(err)-> #Success
      defer.reject(err)
  )

  return defer.promise

onlyVote = (result) ->
  card     = result[0]
  lang     = result[1]
  username = result[2]
  defer    = Q.defer()
  card = {
    id:       card.id
    vote:     card.vote
    rank:     card.rank
  }
  defer.resolve([card, lang, username])
  return defer.promise

getWorkflow = (result)->
  card     = result[0]
  lang     = result[1]
  username = result[2]
  defer = Q.defer()
  view('its/card_workflow', {
    key: card.id
  }).then(
    (data)-> #Success
      data = data[0].value
      if data.cards.hasOwnProperty(card.id)
        card.list_id  = data.cards[card.id].list_id
        card.tag_list = data.cards[card.id].tag_list
      else
        card.list_id = "ideas"
        card.list_id = []

      if data.cost_estimate && data.cost_estimate.hasOwnProperty(card.id)
        card.cost_estimate = data.cost_estimate[card.id]
      else
        card.cost_estimate = null

      if data.payment && data.payment.hasOwnProperty(card.id)
        card.payment = data.payment[card.id]
      else
        card.payment = null

      defer.resolve([card, lang, username])
    ,(err)-> #Error
      defer.reject(err)
  )
  return defer.promise

users = {}
ids   = {}

store = (prev, username, socket) ->
  if users[prev]
    delete users[prev]?[socket.id]
    if Object.keys(users[prev]).length == 0
      delete users[prev]

  if not users[username]
    users[username] = {}
  users[username][socket.id] = socket

io.sockets.on('connection', (socket)->
  project  = ''
  lang     = ''
  username = ''
  password = ''
  cookie   = socket.handshake.headers.cookie
  store('', username, socket)

  socket.on 'disconnect', ->
    delete users[username]?[socket.id]

  socket.on 'setUsername', (data)->
    store(username, data, socket)
    if username != ''
      socket.leave("username:#{username}")
    socket.join("username:#{username}")
    username = data
  socket.on 'setPassword', (data)->
    password = data
  socket.on 'setProject',  (data)->
    project = data
  socket.on 'setLang',     (data)->
    if lang != ''
      socket.leave("lang:#{data}")
    socket.join("lang:#{data}")
    lang = data

  socket.on 'getAll', (data)->
    getCards(project).then( (cards)->
      cards.forEach( (card) ->
        ids[card.id] = true
        getCard(card, lang, username)
          .then(withoutDescription)
          .then(getWorkflow)
          .then(
            (card)-> #Success
              socket.emit('setCard', card[0])
            ,(err)-> #Error
              console.log err
          )
      )
    )

  socket.on 'getDescription', (id)->
    getCard(id, lang, username)
      .then(onlyDescription)
      .then(
        (card)-> #Success
          socket.emit('setCard', card[0])
        ,(err)-> #Error
          console.log err
      )

  socket.on 'getActivity', (id)->
    view('its/comment_all', {
      startkey: ["card:#{id}", 0]
      endkey:   ["card:#{id}", {}]
    }).then(
      (data)-> #Success
        data.forEach (comment)->
          socket.emit('addActivity', comment)
      ,(err)-> #Error
        console.log err
    )
    view('its/activity_all', {
      startkey: ["card:#{id}", 0]
      endkey:   ["card:#{id}", {}]
    }).then(
      (data)-> #Success
        data.forEach (activity)->
          socket.emit('addActivity', activity)
      ,(err)-> #Error
        console.log err
    )

  socket.on 'getTitle', ->
    getCards(project).then( (cards)->
      cards.forEach( (card) ->
        getCard(card, lang, username)
          .then(onlyTitle)
          .then(
            (card)-> #Success
              socket.emit('setCard', card[0])
            ,(err)-> #Error
              console.log err
          )
      )
    )

  socket.on 'getVote', ->
    getCards(project).then( (cards)->
      cards.forEach( (card) ->
        getVote([card.id, lang, username])
          .then(
            (card)-> #Success
              socket.emit('setCard', card[0])
            ,(err)-> #Error
              console.log err
          )
      )
    )

  socket.on 'updateField', (value, fn) ->
    update('its/card_update_field', "card:#{value.id}", value, {
      cookie:   cookie
      user:     username
      password: password
    }).then(
      (data)-> #Success
        fn("Done:#{data.response}")
        id = data.id.split(':')[1]
        getCard(id, lang, username)
          .then(
            (data)-> #Success
              data = data[0]
              result = {
                id: data.id
              }
              if value.element == 'title'
                result.title = data.title
              else if value.element == 'description'
                result.description = data.description

              io.sockets.in("lang:#{lang}").emit('setCard', result)
            ,(err)-> #Error
              console.log err
          )
      ,(err)-> #Error
        fn("Error:#{ JSON.stringify(err.response) }")
    )

  socket.on 'newComment', (data, fn)->
    update('its/comment_create', '', data, {
      cookie:   cookie
      user:     username
      password: password
    }).then(
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
    data.id = "#{data.project_id}.#{createID(ids)}"
    update('its/card_create', '', data, {
      cookie:   cookie
      user:     username
      password: password
    }).then(
      (data)-> #Success
        fn("Done:#{data.response}")
        id = data.id.split(':')[1]
        getCard(id, lang, username)
          .then(withoutDescription)
          .then(getVote)
          .then(getWorkflow)
          .then(
            (data)-> #Success
              io.sockets.emit('addCard', data[0])
            ,(err)-> #Error
              console.log err
          )
      ,(err)-> #Error
        fn("Error:#{err.response}")
    )

  socket.on 'setSubscription', (data, fn)->
    promise = null
    user = {
      user:     username
      password: password
      cookie:   cookie
    }

    if not data.check
      promise = update('its/subscription_create', '', {
        object_key: data.id
      }, user)
    else
      promise = update('its/subscription_delete', "subscription:#{data.id}-#{username}", {}, user)

    promise.then(
      (res)-> #Succes
        fn("Done:#{res.response}")
      ,(err)-> #Error
        fn("Error:#{JSON.stringify(err.response)}")
    )

  socket.on 'setVote', (data, fn)->
    promise = null
    if not data.check
      promise = update('its/vote_create', '', {
        object_id: data.id
        element:   data.element
      }, {
        cookie:   cookie
        user:     username
        password: password
      })
    else
      promise = update('its/vote_delete', "vote:card:#{data.id}-#{username}", {}, {
        cookie:   cookie
        user:     username
        password: password
      })

    promise.then(
      (res)-> #Succes
        fn("Done:#{res.response}")
        getVote([data.id, lang, username])
          .then(onlyVote)
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
