ng.factory('login', ($q, User) ->
  return {
    actualUser: {}

    session: require('session')

    signIn: (user, password) ->
      defer = $q.defer()
      _this = this
      User.get({
        id: 'user-' + user
      }).then(
        (data) -> #Success
          _this.session.login(user, password, (err, response) ->
            if not err
              _this.actualUser = response
              defer.resolve(response)
            else
              defer.reject(err)
          )
        ,(err) -> #Error
          defer.reject(err)
      )
      return defer.promise

    logout: ->
      defer = $q.defer()
      _this = this
      this.session.logout( (err, response) ->
        if not err
          _this.actualUser = {
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
          _this.actualUser = info
          defer.resolve(info)
        else
          defer.reject(err)
      )
      return defer.promise

    isConnect: ->
      return this.actualUser.name? and this.actualUser.name != ''

  }
)
