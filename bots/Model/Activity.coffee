db = require('../db')()

module.exports = {
  all: (id)=>
    return db.view('activity_all', {
      startkey: [id, 0]
      endkey:   [id, {}]
    })
}
