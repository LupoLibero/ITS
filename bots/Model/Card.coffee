db = require('../db')
Q  = require('q')

getRandomChar = ->
  chars = "1234567890abcdefghijklmnopqrstuvwxyz"
  num   = Math.floor(Math.random() * chars.length)
  return chars.charAt(num)

getLang = (card, element, lang)->
  if card[element]?.hasOwnProperty(lang)
    card[element]      = card[element][lang]
    card[element].lang = lang
  else
    card[element]      = card[element][card.init_lang]
    card[element].lang = card.init_lang

createID = (ids={}, num=3, count=1)->
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

module.exports = {
  all: (project)=>
    return db.view('card_all', {
      startkey: "#{project}."
      endkey:   "#{project}.a"
    })

  create: (data, user, ids)=>
    data.id = "#{data.project_id}.#{createID(ids)}"
    console.log data.id
    return db.update('card_create', '', data, user)

  updateField: (value, user)=>
    return db.update('card_update_field', "card:#{value.id}", value, user)

  translate: (result)=>
    defer = Q.defer()
    card  = result[0]
    lang  = result[1]
    user  = result[2]

    card.num = card.id.split('.')[1]
    getLang(card, 'title', lang)
    getLang(card, 'description', lang)

    delete card.init_lang
    delete card.type
    defer.resolve([card, lang, user])
    return defer.promise

  get: (result)=>
    defer = Q.defer()
    id    = result[0]
    lang  = result[1]
    user  = result[2]

    db.view('card_all', {
      key: id
    }).then(
      (data)->
        defer.resolve([data[0].value, lang, user])
      ,(err)->
        defer.reject(err)
    )
    return defer.promise

  withoutDescription: (result)=>
    defer = Q.defer()
    delete result[0].description
    defer.resolve(result)
    return defer.promise

  onlyTitle: (result)=>
    card     = result[0]
    defer    = Q.defer()
    card = {
      id:     card.id
      title:  card.title
    }
    result[0] = card
    defer.resolve(result)
    return defer.promise

  onlyDescription: (result)=>
    card     = result[0]
    defer    = Q.defer()
    card = {
      id:           card.id
      description:  card.description
    }
    result[0] = card
    defer.resolve(result)
    return defer.promise

  getWorkflow: (result)=>
    defer = Q.defer()
    card  = result[0]
    lang  = result[1]
    user  = result[2]

    db.view('card_workflow', {
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

        defer.resolve([card, lang, user])
      ,(err)-> #Error
        defer.reject(err)
    )
    return defer.promise
}
