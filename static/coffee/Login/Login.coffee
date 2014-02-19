ng.factory('login', ($q) ->
  return {
    user: {}

    session: require('session')

    signin: (login, password) ->
      defer = $q.defer()
      _this = this
      this.session.login(login, password, (err, response) ->
        if not err
          _this.user = response
          defer.resolve(response)
        else
          defer.reject(err)
      )
      return defer.promise

    logout: ->
      defer = $q.defer()
      _this = this
      this.session.logout( (err, response) ->
        if not err
          _this.user = {
            name: response.name
            role: response.role
          }
          defer.resolve(response)
        else
          defer.reject(err)
      )
      return defer.promise

    getInfo: ->
      defer = $q.defer()
      _this = this
      this.session.info( (err, info)->
        if not err
          info = info.userCtx
          _this.user = info
          defer.resolve(info)
        else
          defer.reject(err)
      )
      return defer.promise

    isConnect: ->
      return this.user.name? and this.user.name != ''
  }
)
