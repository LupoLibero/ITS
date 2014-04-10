io     = require('socket.io').listen(8800)
Q      = require('q')
cradle = require('cradle')
db     = new(cradle.Connection)('http://127.0.0.1', 5984, { cache: false }).database('lupolibero')
view   = Q.nbind(db.view, db)
update = Q.nbind(db.update, db)

getCards = (project)->
  return view('its/card_all')

getCard = (card, lang, username)->
  defer = Q.defer()
  card.num = card.id.split('.')[1]

  if card.title.hasOwnProperty(lang)
    card.title = card.title[lang]
    card.lang  = lang
  else
    card.title = card.title[card.init_lang]
    card.lang  = card.init_lang

  defer.resolve([card, lang, username])
  return defer.promise

onlyTitle = (result) ->
  card     = result[0]
  lang     = result[1]
  username = result[2]
  defer = Q.defer()
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
  defer = Q.defer()
  card = {
    id:       card.id
    vote:     card.vote
    rank:     card.rank
    hasVote:  card.hasVote
  }
  defer.resolve([card, lang, username])
  return defer.promise

onlyVote = (result) ->
  card     = result[0]
  lang     = result[1]
  username = result[2]
  defer = Q.defer()
  card = {
    id:       card.id
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

io.sockets.on('connection', (socket)->
  project  = ''
  lang     = ''
  username = ''

  socket.on 'setUsername', (data)->
    username = data
  socket.on 'setProject',  (data)->
    project = data
  socket.on 'setLang',     (data)->
    lang = data

  socket.on 'getAll', (data)->
    lang = data

    getCards(project).then( (cards)->
      cards.forEach( (card) ->

        getCard(card, lang, username)
          .then(getVote)
          .then(getWorkflow)
          .then(
            (card)-> #Success
              socket.emit('addCard', card[0])
            ,(err)-> #Error
              console.log err
          )
      )
    )

  socket.on 'getTitle', (data)->
    lang = data

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
  socket.on 'newCard', (data) ->
    console.log data
    promise = update('its/card_create', '', data).then(
      (data) -> #Success
        console.log data
      ,(err) -> #Error
        console.log err
    )

  socket.on 'setVote', (data) ->
    if not data.check
      promise = update('its/vote_create', '', data)
    else
      promise = update('its/vote_delete', "vote:card:#{data.id}-#{username}")

    promise.then(
      (data) ->
        console.log data
      ,(err) ->
        console.log err
    )

) #Socket on connection
