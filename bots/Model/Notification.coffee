db   = require('../db')()
Q    = require('q')
user = require('../config.json').notification_manager

module.exports = {
  all: =>
    return db.view('notification_all')

  hasBeenSend: (notification)=>
    return db.update('notification_displayed', notification._id, {}, user)

  create: (template)=>
    return db.update('notification_create', '', template, user)
}
