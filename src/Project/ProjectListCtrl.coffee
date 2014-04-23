angular.module('project').
controller('ProjectListCtrl', ($scope, $state, projects_default, projects) ->
  $scope.projects = angular.extend(projects_default, projects)

  # # If only one project go directly to him
  if projects.length == 1
    $state.go('card', {
      project_id: projects[0].id
    })
)
