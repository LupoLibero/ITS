angular.module('project').
controller('ProjectListCtrl', ($scope, projects_default, projects, url) ->

  $scope.projects = angular.extend(projects_default, projects)

  # If only one project go directly to him
  if projects.length == 1
    route = url.get('project.show', {
      project_id: project.id
    })
    $location.path(route)
)
