db = require('../db')

module.exports = {
  get: (id)=>
    return db.view('its/activity_all', {
      startkey: ["card:#{id}", 0]
      endkey:   ["card:#{id}", {}]
    })
}
