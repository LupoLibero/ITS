ng.controller('TicketCtrl', ($scope, project, ticket, categories, statuses, resolutions) ->
  $scope.project     = project
  $scope.ticket      = ticket
  $scope.categories  = categories
  $scope.statuses    = statuses
  $scope.resolutions = resolutions
)
