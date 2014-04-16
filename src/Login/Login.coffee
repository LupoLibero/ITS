angular.module('login').
factory('login', ($q, $rootScope, $timeout, $http) ->
  login = {
    actualUser: {}

    users:   require('users')

    getName: ->
      if this.isConnect()
        return this.actualUser.name
      else
        return ''

    signIn: (user, password) ->
      defer = $q.defer()

      $http.post("/_session", {
        name:     user
        password: password
      }).then(
        (data)=> #Success
          @actualUser = data.data
          $rootScope.$broadcast('SignIn', @getName() )
          $rootScope.$broadcast('SessionChanged', @getName())
          defer.resolve(data)
        ,(err)-> #Error
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

      $http.delete('/_session').then(
        (data) => #Success
          data = data.data
          @actualUser = {
            name: data.name
            role: data.role
          }
          $rootScope.$broadcast('SignOut')
          $rootScope.$broadcast('SessionChanged', @getName())
          defer.resolve(data)
        ,(err) => #Error
          defer.reject(err)
      )

      return defer.promise

    getInfo: ->
      defer = $q.defer()

      $http.get('/_session').then(
        (data) => #Success
          data = data.data.userCtx
          @actualUser = data
          $timeout( =>
            $rootScope.$broadcast('SessionStart', @getName())
            $rootScope.$broadcast('SessionChanged', @getName())
            if @isConnect()
              $rootScope.$broadcast('SignIn', @getName())
            else
              $rootScope.$broadcast('SignOut')
          , 100)
          defer.resolve(data)
        ,(err) => #Error
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
