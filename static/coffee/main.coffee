ng = angular.module('its', ['ngRoute', 'ngCouchDB'])

ng.constant('dbUrl', 'http://127.0.0.1:5984/')

ng.config( ($routeProvider)->
  $routeProvider
    .when('/', {
      templateUrl: 'partials/project/list.html'
      controller:  'ProjectListCtrl'
    })
    .when('/project/:id', {
      templateUrl: 'partials/project/show.html'
      controller:  'ProjectCtrl'
      resolve: {
        project: (Project, $route) ->
          id = $route.current.params.id
          return Project.get({
            id:id
          })
      }
    })
    .otherwise({redirectTo: '/'})
)
