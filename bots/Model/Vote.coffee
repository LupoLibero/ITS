db = require('../db')()
Q  = require('q')

module.exports = {
  set: (data, user)=>
    return db.update('vote_create', '', {
      object_id: data.id
      element:   data.element
    }, user)

  unset: (data, user)=>
    _id = "vote:#{data.element}:#{data.id}-#{user.name}"
    return db.update('vote_delete', _id, {}, user)

  get: (result)=>
    defer = Q.defer()
    doc   = result[0]
    lang  = result[1]
    user  = result[2]

    if typeof doc != 'object'
      doc = { _id: doc }

    db.view('vote_all', {
      key: doc._id
    }).then(
      (data)-> #Success
        result = {}
        for row in data
          for username, vote of row.value
            result[username] = vote

        doc.rank = Object.keys(result).length
        if result.hasOwnProperty(user.name)
          doc.vote = user.name
        else
          doc.vote = null

        doc.id = doc._id.split(':')[1..-1].join(':')
        delete doc._id
        defer.resolve([doc, lang, username])
      ,(err)-> #Success
        defer.reject(err)
    )
    return defer.promise
}
