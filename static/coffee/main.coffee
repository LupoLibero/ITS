ng = angular.module('its', ['ngRoute', 'ngCouchDB', 'ui.bootstrap', 'pascalprecht.translate', 'angularSpinner'])

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
    .when('/project/:project_id/demand', {
      templateUrl: 'partials/demand/list.html'
      controller:  'DemandListCtrl'
      name:        'demand.list'
      resolve: {
        demands_default: (Demand, $route) ->
          id = $route.current.params.project_id
          return Demand.all({
            descending: true
            startkey: [id, 'default', "\ufff0"]
            endkey: [id, 'default', 0]
          })
        demands: (Demand, $route, $translate) ->
          language = window.navigator.language
          id = $route.current.params.project_id
          return Demand.all({
            descending: true
            startkey: [id, language, "\ufff0"]
            endkey: [id, language, 0]
          })
        project: (Project, $route) ->
          return Project.getDoc({
            id: $route.current.params.project_id
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
    .when('/project/:project_id/demand/:demand_id/:onglet?', {
      templateUrl: 'partials/demand/show.html'
      controller:  'DemandCtrl'
      name:        'demand.show'
      resolve: {
        demand_default: (Demand, $route) ->
          return Demand.get({
            key: [$route.current.params.demand_id, 'default']
          })
        demand: (Demand, $route) ->
          return Demand.view({
            view: 'get'
            key:  [$route.current.params.demand_id, window.navigator.language]
          })
        project: (Project, $route) ->
          return Project.getDoc({
            id: $route.current.params.project_id
          })
        comments: (Comment, $route) ->
          id = "demand-#{$route.current.params.demand_id}"
          return Comment.all({
            endkey:   [id,0]
            startkey: [id,"\ufff0"]
            descending: true
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
          id = "demand-#{$route.current.params.demand_id}"
          return Activity.all({
            descending: true
            startkey: [id,"\ufff0"]
            endkey: [id,0]
          })
      }
    })
    .when('/blog', {
      templateUrl: ''
      controller:  ''
      name:        'blog'
      resolve: {
      }
    })
    .otherwise({redirectTo: '/project'})
)
