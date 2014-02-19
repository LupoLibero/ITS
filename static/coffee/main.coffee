ng = angular.module('its', ['ngRoute', 'ngCouchDB', 'ui.bootstrap'])

ng.value('name', 'lupolibero-its')
ng.value('dbUrl', 'http://127.0.0.1:5984/lupolibero')
ng.value('lng', 'en')

ng.config( ($routeProvider)->
  $routeProvider
    .when('/', {
      templateUrl: 'partials/project/list.html'
      controller:  'ProjectListCtrl'
      resolve: {
        projects: (Project)->
          return Project.all()
      }
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
    .when('/project/:id/ticket', {
      templateUrl: 'partials/ticket/list.html'
      controller:  'TicketCtrl'
      resolve: {
        tickets: (Ticket, $route) ->
          id = $route.current.params.id
          return Ticket.all({
            descending: true
            startkey: [id,"\ufff0"]
            endkey: [id,0]
          })
      }
    })
    .otherwise({redirectTo: '/'})
)
