db = require('../db')()

module.exports = {
  all: (id)=>
    return db.view('comment_all', {
      startkey: [id, 0]
      endkey:   [id, {}]
    })

  create: (data, user)=>
    return db.update('comment_create', '', data, user)
}
