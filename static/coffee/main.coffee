ng = angular.module('its', ['ngRoute', 'ngCouchDB'])

ng.value('name', 'lupolibero-its')
ng.value('dbUrl', 'http://127.0.0.1:5984/lupolibero')
ng.value('lng', 'en')

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
          Project.get({
            id: 'project-'+id
          })
      }
    })
    .otherwise({redirectTo: '/'})
)
