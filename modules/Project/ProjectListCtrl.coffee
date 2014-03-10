angular.module('project').
controller('ProjectListCtrl', ($scope, projects, url) ->
  # If only one project go directly to him
  if projects.length == 1
    route = url.get('project.show', {
      project_id: project.id
    })
    $location.path(route)

  # Put projects in the scope
  $scope.projectList = projects
)
