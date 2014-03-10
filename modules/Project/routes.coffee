angular.module('project').
config( ($routeProvider)->
  $routeProvider
    .when('/project', {
      templateUrl: 'partials/project/list.html'
      controller:  'ProjectListCtrl'
      name:        'project.list'
      resolve: {
        projects: (Project)->
          return Project.all()
      }
    })
    .when('/project/:project_id', {
      templateUrl: 'partials/project/show.html'
      controller:  'ProjectCtrl'
      name:        'project.show'
      resolve: {
        project: (Project, $route) ->
          return Project.getDoc({
            id: $route.current.params.project_id
          })
      }
    })
)
