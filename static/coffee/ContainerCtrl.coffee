ng.controller('ContainerCtrl', ($scope, notification, url, $rootScope) ->
  $rootScope.url = url
  $scope.notif   = notification
)
