ng.controller('TicketCtrl', ($scope, project, ticket, config) ->
  $scope.project     = project
  $scope.ticket      = ticket
  $scope.categories  = config[0].value
  $scope.resolutions = config[1].value
  $scope.statuses    = config[2].value
)
