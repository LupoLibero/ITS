config = require('./config.json').db
http   = require('http')
Q      = require('q')
cradle = require('cradle')

module.exports = (dbname)->
  dbname ?= config.database
  db      = new(cradle.Connection)("http://#{config.host}", config.port, { cache: false }).database(dbname)
  return {
    changes: (data) ->
      return db.changes(data)

    view: (v, data = {}) ->
      defer = Q.defer()
      db.view("#{config.name}/#{v}", data, (err, data)->
        if err
          defer.reject(err)
        else
          defer.resolve(data)
      )
      return defer.promise

    update: (updateName, id = '', data = {}, user = {}) ->
      defer  = Q.defer()
      method = (if id is '' then 'POST' else 'PUT')

      if user.pass != '' and user.pass?
        basic = new Buffer("#{user.name}:#{user.pass}").toString('base64')
        headers = {
          "Authorization": "Basic #{basic}"
        }
      else if user.name != '' and user.cookie != ''
        headers = {
          "Cookie": user.cookie
        }
      else
        hearders = {}

      req = http.request({
        hostname:  config.host
        method:    method
        port:      config.port
        path:      "/#{config.database}/_design/#{config.name}/_update/#{updateName}/#{id}"
        headers:   headers
      }, (res)->
        res.setEncoding('utf8')
        res.on('data', (body)->
          try
            body = JSON.parse(body)

          data = {
            response: body
            status:   res.statusCode
          }

          if res.headers.hasOwnProperty('x-couch-update-newrev')
            data.rev = res.headers['x-couch-update-newrev']
          if res.headers.hasOwnProperty('x-couch-id')
            data._id  = res.headers['x-couch-id']
            data.id   = data._id.split(':')[1..-1].join(':')

          if res.statusCode.toString()[0] > 3
            defer.reject(JSON.stringify(data))
          else
            data = {
              reason:  body.reason?
              error:   body.error?
              status:  res.statusCode
            }
            defer.resolve(data)
        )
      )
      req.write(JSON.stringify(data))
      req.end()
      return defer.promise
  }
