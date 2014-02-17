ng.controller('ProjectListCtrl', ($scope, Project) ->
  $scope.content=
    title: "Project List"

  $scope.projectList = Project.query()
)
