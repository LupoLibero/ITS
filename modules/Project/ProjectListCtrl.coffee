angular.module('project').
controller('ProjectListCtrl', ($scope, projects_default, projects, url) ->
  # Replace the default project by the translate project
  for project, i in projects_default
    for trad in projects
      if trad.id == project.id
        project_default[i] = trad

  # If only one project go directly to him
  if projects.length == 1
    route = url.get('project.show', {
      project_id: project.id
    })
    $location.path(route)

  # Put projects in the scope
  $scope.projects = projects_default
)
