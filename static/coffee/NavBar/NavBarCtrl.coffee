ng.controller('NavBarCtrl', ($scope) ->
  # Module
  session = require('session')

  # User Object
  $scope.user= {}
  $scope.loginform=
    login:    ''
    password: ''

  # LogOut User
  $scope.logout = ->
    console.log "logout"
    session.logout()
    $scope.user.name = null

  # Login User
  $scope.login = ->
    console.log "login"
    login    = $scope.loginform.login
    password = $scope.loginform.password
    if login isnt '' and password isnt ''
      session.login(login, password, (err, response) ->
        $scope.loginform.password = ''
        if response isnt undefined
          $scope.loginform.login = ''
      )

  $scope.userIsConnected = ->
    return $scope.user.name? and $scope.user.name isnt null

  # Get the current session
  session.info( (err, info)->
    if not err
      $scope.user = info
  )

  # On Session change
  session.on('change', (user) ->
    $scope.user = user
    $scope.$apply()
  )
)
