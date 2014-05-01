db = require('../db')()

module.exports = {
  get: (id)=>
    return db.view('subscription_by_object_key', {
      startkey: [id, ""]
      endkey:   [id, {}]
    })

  set: (req, user)=>
    return db.update('subscription_create', '', {
      object_key: req.id
    }, user)

  unset: (req, user)=>
    return db.update('subscription_delete',
                    "subscription:#{req.id}-#{user.name}", {}, user)
}
