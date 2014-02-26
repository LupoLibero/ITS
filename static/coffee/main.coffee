ng = angular.module('its', ['ngRoute', 'ngCouchDB', 'ui.bootstrap', 'pascalprecht.translate'])

ng.value('name', 'lupolibero-its')
ng.value('dbUrl', '/lupolibero')

ng.config( ($routeProvider, $translateProvider)->
  # $locationProvider.html5Mode(true)

  # Translations
  $translateProvider.useLoader('translation')

  # Routes
  $routeProvider
    .when('/project', {
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
    .when('/project/:id/demand', {
      templateUrl: 'partials/demand/list.html'
      controller:  'DemandListCtrl'
      resolve: {
        demands: (Demand, $route) ->
          id = $route.current.params.id
          return Demand.all({
            descending: true
            startkey: [id,"\ufff0"]
            endkey: [id,0]
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
    .when('/project/:id/demand/:demandID/:onglet?', {
      templateUrl: 'partials/demand/show.html'
      controller:  'DemandCtrl'
      resolve: {
        demand: (Demand, $route) ->
          demandID  = $route.current.params.demandID
          projectid = $route.current.params.id
          id = projectid.toUpperCase() + '#' + demandID
          return Demand.get({
            id: 'demand-' + id
          })
        project: (Project, $route) ->
          id = $route.current.params.id
          return Project.get({
            id: 'project-' + id
          })
        comments: (Comment) ->
          return Comment.all({
            descending: true
            limit:      10
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
        histories: ($q, Activity, $route) ->
          if not $route.current.params.onglet
            return false

          demandID  = $route.current.params.demandID
          projectid = $route.current.params.id
          id = "demand-" + projectid.toUpperCase() + '#' + demandID

          return Activity.all({
            descending: true
            startkey: [id,"\ufff0"]
            endkey: [id,0]
          })
      }
    })
    .otherwise({redirectTo: '/project'})
)
