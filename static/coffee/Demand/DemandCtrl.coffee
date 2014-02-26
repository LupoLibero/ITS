ng.controller('DemandCtrl', ($scope, $route, Activity, $location) ->
  $scope.project     = $route.current.locals.project
  $scope.demand      = $route.current.locals.demand
  $scope.categories  = $route.current.locals.config[0].value
  $scope.resolutions = $route.current.locals.config[1].value
  $scope.statuses    = $route.current.locals.config[2].value
)
