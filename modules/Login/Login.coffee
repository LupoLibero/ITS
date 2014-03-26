angular.module('login').
factory('login', ($q, User, $rootScope, $timeout) ->
  login = {
    actualUser: {}

    session: require('session')
    users:   require('users')

    getName: ->
      if this.isConnect()
        return this.actualUser.name
      else
        return ''

    signIn: (user, password) ->
      defer = $q.defer()
      _this = this
      this.session.login(user, password, (err, response) ->
        if not err
          _this.actualUser = response
          $rootScope.$broadcast('SignIn', _this.getName() )
          $rootScope.$broadcast('SessionChanged', _this.getName())
          defer.resolve(response)
        else
          defer.reject(err)
      )
      return defer.promise

    signUp: (user) ->
      defer = $q.defer()
      _this = this
      # Create the user inside _users db
      this.users.create(user.name, user.password, {email: user.email}, (err, response) ->
        if err
          defer.reject(err)
        else
          _this.signIn(user.name, user.password).then(
            (data) -> #Success
              defer.resolve(data)
            ,(err) -> #Error
              defer.reject(err)
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
          $rootScope.$broadcast('SessionChanged', _this.getName())
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
          $timeout( ->
            $rootScope.$broadcast('SessionStart', _this.getName())
            $rootScope.$broadcast('SessionChanged', _this.getName())
            if _this.isConnect()
              $rootScope.$broadcast('SignIn', _this.getName())
            else
              $rootScope.$broadcast('SignOut')
          ,100)
          defer.resolve(info)
        else
          defer.reject(err)
      )
      return defer.promise

    isConnect: ->
      return this.actualUser.name? and this.actualUser.name != ''

    isNotConnect: ->
      if not this.actualUser.hasOwnProperty('name')
        return false
      else
        return !this.isConnect()

    hasRole: (role) ->
      if this.actualUser.hasOwnProperty('roles')
        for piece in this.actualUser.roles
          if role == piece or piece == 'admin'
            return true
      # Otherwise
      return false
  }

  $rootScope.$on('$routeChangeSuccess', ->
    $timeout( ->
      $rootScope.$broadcast('SessionChanged', login.getName())
      if login.isConnect()
        $rootScope.$broadcast('SignIn', login.getName())
      else
        $rootScope.$broadcast('SignOut', login.getName())
    ,200)
  )

  return login
)
