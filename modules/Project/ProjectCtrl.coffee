angular.module('project').
controller('ProjectCtrl', ($scope, $route) ->
  # If a traduction is available
  if $route.current.locals.project.length != 0
    $scope.project = $route.current.locals.project[0]
  else
    $scope.project = $route.current.locals.project_default
)
