db = require('../db')

module.exports = {
  all: (id)=>
    return db.view('its/comment_all', {
      startkey: ["card:#{id}", 0]
      endkey:   ["card:#{id}", {}]
    })

  create: (data, user)=>
    retur db.update('comment_create', '', data, user)
}
