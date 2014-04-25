db = require('../db')
Q  = require('q')

module.exports = {
  set: (data, user)=>
    return db.update('vote_create', '', {
      object_id: data.id
      element:   data.element
    }, user)

  unset: (data, user)=>
    _id = "vote:card:#{data.id}-#{user.name}"
    return db.update('vote_delete', _id, {}, user)

  get: (result)=>
    defer = Q.defer()
    card  = result[0]
    lang  = result[1]
    user  = result[2]

    if typeof card != 'object'
      card = { id: card }

    db.view('vote_all', {
      key: "card:#{card.id}"
    }).then(
      (data)-> #Success
        result = {}
        for row in data
          for username, vote of row.value
            result[username] = vote

        card.rank = Object.keys(result).length
        if result.hasOwnProperty(user.name)
          card.vote = user.name
        else
          card.vote = null

        defer.resolve([card, lang, username])
      ,(err)-> #Success
        defer.reject(err)
    )
    return defer.promise
}
