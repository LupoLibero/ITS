angular.module('login').
controller('SignUpCtrl', ($scope, notification, $modalInstance, login) ->
  $scope.user=
    pseudo:        ""
    password:      ""
    passwordconf:  ""
  $scope.alert= {}

  # On click on SignUp
  $scope.signup = ->
    user = $scope.user

    # If password and it's confirmation don't match
    if user.password != user.passwordconf
      $scope.notif.setAlert('The two password are not the same!', 'danger')
      return false

    # If one field is not fill
    if user.pseudo is '' or user.password is '' or user.passwordconf is ''
      $scope.notif.setAlert('Please fill all the fields!')
      return false

    # SignUp
    login.signUp(user.pseudo, user.password).then(
      (data) -> #Sucess
        $modalInstance.close(data)
      ,(err) -> #Error
        console.log err
        $scope.notif.setAlert('This username is already taken!', 'danger')
    )

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

)
