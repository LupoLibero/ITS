db = require('../db')('_users')
Q  = require('q')

module.exports = {
  get: (username)->
    defer = Q.defer()
    console.log username
    db.view('user_all', {
      key: username
    }).then(
      (data)-> #Success
        console.log data
        if data.length > 0
          defer.resolve(data[0].value)
        else
          defer.reject('not found')
      ,(err)-> #Error
        defer.reject(err)
    )
    return defer.promise

  saveToken: (data)=>
    return db.update('user_field', "org.couchdb.user:#{data.subscriber}", {
      element: 'token'
      value:   data.token
    })
}
