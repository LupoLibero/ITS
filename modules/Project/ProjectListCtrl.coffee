angular.module('project').
controller('ProjectListCtrl', ($scope, projects) ->
  # Put projects in the scope
  $scope.projectList = projects
)
