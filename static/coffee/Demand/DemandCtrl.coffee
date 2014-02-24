ng.controller('DemandCtrl', ($scope, project, demand, config) ->
  $scope.project     = project
  $scope.demand      = demand
  $scope.categories  = config[0].value
  $scope.resolutions = config[1].value
  $scope.statuses    = config[2].value
)
