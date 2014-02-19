ng.controller('ContainerCtrl', ($rootScope) ->
  $rootScope.alerts = []

  $rootScope.addAlert = (message, type) ->
    alert=
      message:  message
      type:     type
    $rootScope.alerts.push(alert)

  $rootScope.closeAlert = (index) ->
    $rootScope.alerts.splice(index, 1)
)
