db = require('../db')()

module.exports = {
  get: (id)=>
    return db.view('subscription_by_object_key', {
      startkey: [id, ""]
      endkey:   [id, {}]
    })

  set: (_id, user)=>
    return db.update('subscription_create', '', {
      object_key: _id
    }, user)

  unset: (_id, user)=>
    return db.update('subscription_delete',
                     "subscription:#{_id}-#{user.name}", {}, user)
}
