angular.module('navbar').
controller('NavBarCtrl', ($scope, login, $modal, notification) ->
  # User Object
  $scope.loginform=
    user:      ''
    password:  ''
  $scope.login = login

  # Get the session
  login.getInfo()

  $scope.$on('SignOut', ->
    $scope.$apply()
  )

  # login User
  $scope.signIn = ->
    user     = $scope.loginform.user
    password = $scope.loginform.password

    # If one field is empty
    if user is '' or password is ''
      notification.addAlert('Please fill both of the fields!', 'danger')
      return false

    # SignIn
    login.signIn(user, password).then(
      (data)-> #Success
        $scope.loginform.password = ''
        $scope.loginform.user = ''
      ,(err) -> #Error
        $scope.loginform.password = ''
        notification.addAlert('The username or/and password are/is not correct', 'danger')
    )

  $scope.signup = ->
    modalSignUp = $modal.open({
      templateUrl: '../partials/signup.html'
      controller:  'SignUpCtrl'
    })
)
