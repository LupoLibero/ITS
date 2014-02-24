ng.factory('login', ($q, User, $rootScope) ->
  return {
    actualUser: {}

    session: require('session')
    users: require('users')

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
              $rootScope.$broadcast('SignIn')
              defer.resolve(response)
            else
              defer.reject(err)
          )
        ,(err) -> #Error
          defer.reject(err)
      )
      return defer.promise

    signUp: (user, password) ->
      defer = $q.defer()
      _this = this
      this.users.create(user, password, {}, (err, response) ->
          if err
            defer.reject(err)
          else
            add = new User
            add.id = user
            add.username = user
            add.$save().then(
              ()->
                _this.signIn(user, password).then(
                  (data) ->
                    defer.resolve(data)
                )
            )
      )
      return defer.promise

    signOut: ->
      defer = $q.defer()
      _this = this
      this.session.logout( (err, response) ->
        if not err
          _this.actualUser = {
            name: response.name
            role: response.role
          }
          $rootScope.$broadcast('SignOut')
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
