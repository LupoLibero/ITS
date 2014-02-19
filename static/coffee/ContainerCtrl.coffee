ng.controller('ContainerCtrl', ($rootScope) ->
  $rootScope.alerts = []

  $rootScope.addAlert = (message, type) ->
    add=
      message:  message
      type:     type

    found = false
    for alert in $rootScope.alerts
      if alert.message == add.message
        found = true
        break

    if not found
      $rootScope.alerts.push(add)

  $rootScope.closeAlert = (index) ->
    $rootScope.alerts.splice(index, 1)
)
