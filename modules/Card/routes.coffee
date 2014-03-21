angular.module('card').
config( ($routeProvider, $translateProvider)->
  $routeProvider
    .when('/project/:project_id/card', {
      templateUrl: 'partials/card/list.html'
      controller:  'CardListCtrl'
      name:        'card.list'
      resolve: {
        cards_default: (Card, $route) ->
          project_id = $route.current.params.project_id
          return Card.all({
            startkey:    [project_id, 'default']
            endkey:      [project_id, 'default', {}]
            group_level: 2
          })
        cards: (Card, $route) ->
          language   = window.navigator.language
          project_id = $route.current.params.project_id
          return Card.all({
            startkey:    [project_id, language]
            endkey:      [project_id, language, {}]
            group_level: 2
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
    .when('/project/:project_id/card/:card_id/:onglet?', {
      templateUrl: 'partials/card/show.html'
      controller:  'CardCtrl'
      name:        'card.show'
      resolve: {
        card_default: (Card, $route) ->
          return Card.get({
            key: [$route.current.params.card_id, 'default']
          })
        card: (Card, $route) ->
          return Card.view({
            view: 'get'
            key:  [$route.current.params.card_id, window.navigator.language]
          })
        project: (Project, $route) ->
          return Project.getDoc({
            id: $route.current.params.project_id
          })
        comments: (Comment, $route) ->
          id = "card-#{$route.current.params.card_id}"
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
          id = "card-#{$route.current.params.card_id}"
          return Activity.all({
            descending: true
            startkey: [id, {}]
            endkey: [id, 0]
          })
      }
    })
)
