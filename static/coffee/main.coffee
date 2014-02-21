ng = angular.module('its', ['ngRoute', 'ngCouchDB', 'ui.bootstrap'])

ng.value('name', 'lupolibero-its')
ng.value('dbUrl', 'http://127.0.0.1:5984/lupolibero')
ng.value('lng', 'en')

ng.config( ($routeProvider, $locationProvider)->
  # $locationProvider.html5Mode(true)

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
          return Project.get({
            id: 'project-'+id
          })
      }
    })
    .when('/project/:id/ticket', {
      templateUrl: 'partials/ticket/list.html'
      controller:  'TicketListCtrl'
      resolve: {
        tickets: (Ticket, $route) ->
          id = $route.current.params.id
          return Ticket.all({
            descending: true
            startkey: [id,"\ufff0"]
            endkey: [id,0]
          })
        project: (Project, $route) ->
          id = $route.current.params.id
          return Project.get({
            id: 'project-' + id
          })
      }
    })
    .when('/project/:id/ticket/:ticketid', {
      templateUrl: 'partials/ticket/show.html'
      controller:  'TicketCtrl'
      resolve: {
        ticket: (Ticket, $route) ->
          ticketid  = $route.current.params.ticketid
          projectid = $route.current.params.id
          id = projectid.toUpperCase() + '#' + ticketid
          return Ticket.get({
            id: 'ticket-' + id
          })
        project: (Project, $route) ->
          id = $route.current.params.id
          return Project.get({
            id: 'project-' + id
          })
        config: ($http, dbUrl, $q, name) ->
          defer = $q.defer()
          $http.get(dbUrl+'/_design/'+name+'/_view/config').then(
            (data) -> #Success
              data = data.data.rows
              defer.resolve(data)
            ,(err) -> #Error
              defer.resolve(err)
          )
          return defer.promise
      }
    })
    .otherwise({redirectTo: '/'})
)
