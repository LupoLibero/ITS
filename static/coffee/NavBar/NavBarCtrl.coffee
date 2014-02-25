ng.controller('NavBarCtrl', ($scope, login, $modal, notification) ->
  # User Object
  $scope.loginform=
    user:      ''
    password:  ''
  $scope.user = {}

  login.getInfo().then(
    (user) ->
      $scope.user = user
  )

  # LogOut User
  $scope.logout = ->
    login.signOut().then(
      ->
        $scope.user = {}
    )

  # login User
  $scope.login = ->
    user     = $scope.loginform.user
    password = $scope.loginform.password

    # If one field is empty
    if user is '' or password is ''
      notification.addAlert('Please fill both of the fields!', 'danger')
      return false

    # SignIn
    login.signIn(user, password).then(
        (data)-> #Success
        $scope.user = data
        $scope.loginform.password = ''
        $scope.loginform.user = ''
      , -> #Error
        $scope.loginform.password = ''
        notification.addAlert('The username or/and password are/is not correct', 'danger')
    )

  $scope.userIsConnected = ->
    return login.isConnect()

  $scope.signup = ->
    modalSignUp = $modal.open({
      templateUrl: '../partials/signup.html'
      controller:  'SignUpCtrl'
    })

    modalSignUp.result.then(
      (data) ->
        $scope.user.name = data.name
    )
)
