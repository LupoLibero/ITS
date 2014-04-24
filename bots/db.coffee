config = require('./config.json').db
http   = require('http')
Q      = require('q')
cradle = require('cradle')
db     = new(cradle.Connection)("http://#{config.host}", config.port, { cache: false }).database(config.database)

module.exports = {
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

    basic = new Buffer("#{user.name}:#{user.password}").toString('base64')
    headers = {
      "Authorization": "Basic #{basic}"
    }

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
          defer.reject(data)
        else
          defer.resolve(data)
      )
    )
    return defer.promise
}
