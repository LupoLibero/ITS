angular.module('project').
controller('ProjectCtrl', ($scope, project) ->
  # put the project in the scope
  $scope.project = project
)
