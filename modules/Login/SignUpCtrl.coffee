angular.module('login').
controller('SignUpCtrl', ($scope, notification, $modalInstance, login) ->
  $scope.user=
    pseudo:        ""
    password:      ""
    email:         ""
    passwordconf:  ""

  # On click on SignUp
  $scope.signup = ->
    user = $scope.user

    # If password and it's confirmation don't match
    if user.password != user.passwordconf
      notification.setAlert('The two password are not the same!', 'danger')
      return false

    # If one field is not fill
    if user.name is '' or user.password is '' or user.passwordconf is '' or user.email is ''
      notification.setAlert('Please fill all the fields!')
      return false

    # SignUp
    login.signUp(user).then(
      (data) -> #Sucess
        $modalInstance.close(data)
      ,(err) -> #Error
        $scope.notif.setAlert('This username is already taken!', 'danger')
    )

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

)
