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
)
