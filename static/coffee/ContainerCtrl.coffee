ng.controller('ContainerCtrl', ($rootScope, $scope, notification, $translate) ->
  $scope.notif = notification

  # Translate
  $translate.use(window.navigator.language)
)
