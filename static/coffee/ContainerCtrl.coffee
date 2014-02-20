ng.controller('ContainerCtrl', ($rootScope, $scope, notification, $translate) ->
  $scope.notif = notification

  # Translate
  $translate.use(window.navigator.language)

  $rootScope.$on('$translateChangeError', () ->
    $translate.use('en')
    notification.addAlert("Your favorite language is not available. The content is displayed with the original language.")
  )
)
