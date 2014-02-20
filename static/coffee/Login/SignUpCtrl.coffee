ng.controller('SignUpCtrl', ($scope, $modalInstance, login) ->
  $scope.user=
    pseudo:      ""
    password:    ""
    passwordconf: ""
  $scope.alert= {}

  $scope.setAlert = (msg, type)->
    $scope.alert= {
        message:  msg
        type:     type
        show:     true
    }

  $scope.closeAlert = () ->
    $scope.alert.show = false

  $scope.displayAlert = () ->
    return $scope.alert.show

  $scope.signup = ->
    user = $scope.user
    if user.pseudo isnt '' and user.password isnt '' and user.passwordconf isnt ''
      if user.password != user.passwordconf
        $scope.setAlert('The two password are not the same!', 'danger')
      else
        login.signUp(user.pseudo, user.password).then(
          (data) -> #Sucess
            $modalInstance.close(data)
          ,(err) -> #Error
            console.log err
            $scope.setAlert('This username is already taken!', 'danger')
        )

    else
      $scope.setAlert('Please fill all the fields!')

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

)
