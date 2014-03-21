angular.module('card').
config( ($routeProvider, $translateProvider)->
  $routeProvider
    .when('/project/:project_id/:card_num?', {
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
        card_default: (Card, $route) ->
          card_num   = $route.current.params.card_num
          project_id = $route.current.params.project_id
          if card_num != undefined
            return Card.get({
              view: 'all'
              key: [project_id, 'default', "#{project_id}.#{card_num}"]
            })
        card: (Card, $route) ->
          card_num   = $route.current.params.card_num
          project_id = $route.current.params.project_id
          if card_num != undefined
            return Card.all({
              key: [project_id, window.navigator.language, "#{project_id}.#{card_num}"]
            })
        config: ($http, db, $q) ->
          defer = $q.defer()
          $http.get("#{db.url}/_design/#{db.name}/_view/config", {
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
)
