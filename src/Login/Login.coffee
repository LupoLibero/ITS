angular.module('login').
factory('login', ($q, $rootScope, $timeout, $http) ->
  login = {
    actualUser: {
      name:     ''
      password: ''
      roles:    []
    }

    getPassword: ->
      if this.isConnect()
        return this.actualUser.password
      else
        return ''

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
          data = data.data
          data['password'] = password
          @actualUser      = data
          $rootScope.$broadcast('SignIn', @getName() )
          $rootScope.$broadcast('SessionChanged', @getName())
          defer.resolve(data)
        ,(err)-> #Error
          defer.reject(err)
      )

      return defer.promise

    signUp: (user) ->
      defer = $q.defer()
      # Create the user inside _users db
      $http.post('/_users/',{
        _id:       "org.couchdb.user:#{user.name}"
        name:      user.name
        type:      "user"
        roles:     []
        password:  user.password
      }).then(
        (data)=> #Success
          @signIn(user.name, user.password).then(
            (data) -> #Success
              defer.resolve(data)
            ,(err) -> #Error
              defer.reject(err)
          )
        ,(err)-> #Error
          defer.reject(err)
      )
      return defer.promise

    signOut: ->
      defer = $q.defer()

      $http.delete('/_session').then(
        (data) => #Success
          data = data.data
          @actualUser = {
            name:     data.name
            password: ''
            role:     data.role
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
      for piece in this.actualUser.roles
        if role == piece or piece == 'admin'
          return true
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
