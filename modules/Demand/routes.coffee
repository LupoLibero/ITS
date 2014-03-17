angular.module('demand').
config( ($routeProvider, $translateProvider)->
  $routeProvider
    .when('/project/:project_id/demand', {
      templateUrl: 'partials/demand/list.html'
      controller:  'DemandListCtrl'
      name:        'demand.list'
      resolve: {
        demands_default: (Demand, $route) ->
          id = $route.current.params.project_id
          return Demand.all({
            descending: true
            startkey: [id, {}, 'default']
            endkey: [id, "", 'default']
            group_level: 3
          })
        demands: (Demand, $route) ->
          lang = window.navigator.language
          id   = $route.current.params.project_id
          return Demand.all({
            descending: true
            startkey: [id, {}, lang]
            endkey: [id, "", lang]
            group_level: 3
          })
        project: (Project, $route) ->
          return Project.getDoc({
            id: $route.current.params.project_id
          })
        config: ($http, db, $q) ->
          defer = $q.defer()
          $http.get(db.url+'/_design/'+db.name+'/_view/config', {
            cache: true
          }).then(
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
            endkey:   [id, 0]
            startkey: [id, {}]
            descending: true
          })
        config: ($http, db, $q) ->
          defer = $q.defer()
          $http.get(db.url+'/_design/'+db.name+'/_view/config', {
            cache: true
          }).then(
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
            startkey: [id, {}]
            endkey: [id, 0]
          })
      }
    })
)
