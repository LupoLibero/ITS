ng.controller('SignUpCtrl', ($scope, notification, $modalInstance, login) ->
  $scope.user=
    pseudo:      ""
    password:    ""
    passwordconf: ""
  $scope.alert= {}

  $scope.notif = notification

  $scope.signup = ->
    user = $scope.user
    if user.pseudo isnt '' and user.password isnt '' and user.passwordconf isnt ''
      if user.password != user.passwordconf
        $scope.notif.setAlert('The two password are not the same!', 'danger')
      else
        login.signUp(user.pseudo, user.password).then(
          (data) -> #Sucess
            $modalInstance.close(data)
          ,(err) -> #Error
            console.log err
            $scope.notif.setAlert('This username is already taken!', 'danger')
        )

    else
      $scope.notif.setAlert('Please fill all the fields!')

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

)
