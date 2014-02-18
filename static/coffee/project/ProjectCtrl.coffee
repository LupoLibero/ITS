ng.controller('ProjectCtrl', ($scope, project) ->
  $scope.content=
    ticket_list: 'Ticket list'
  $scope.project = project
)
