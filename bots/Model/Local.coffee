db = require('../db')

module.exports = {
  set: (key, text, lang, user)->
    data = {
      key: key
      text: text
    }
    return db.update('local_update', "local:#{lang}", data, user)
}
