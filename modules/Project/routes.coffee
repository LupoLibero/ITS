angular.module('project').
config( ($routeProvider)->
  $routeProvider
    .when('/project', {
      templateUrl: 'partials/project/list.html'
      controller:  'ProjectListCtrl'
      name:        'project.list'
      resolve: {
        projects_default: (Project)->
          return Project.all({
            view: 'all'
            startkey: ['default', ""]
            endkey:   ['default', {}]
          })
        projects: (Project)->
          return Project.all({
            view: 'all'
            startkey: [window.navigator.language, ""]
            endkey:   [window.navigator.language, {}]
          })
      }
    })
    .when('/project/:project_id', {
      templateUrl: 'partials/project/show.html'
      controller:  'ProjectCtrl'
      name:        'project.show'
      resolve: {
        project_default: (Project, $route) ->
          return Project.get({
            view: 'all'
            key:  ['default', "project:#{$route.current.params.project_id}"]
          })
        project: (Project, $route) ->
          return Project.all({
            key: [window.navigator.language, "project:#{$route.current.params.project_id}"]
          })
        activities: (Activity, $route) ->
          id = $route.current.params.project_id
          Activity.all({
            endkey: ["demand-#{id}#", 0]
            startkey: ["demand-#{id}#a", {}]
            descending: true
            limit: 10
          })
      }
    })
)
