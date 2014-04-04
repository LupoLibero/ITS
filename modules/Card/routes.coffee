angular.module('card').
config( ($routeProvider)->
  $routeProvider
    .when('/project/:project_id/:card_num?', {
      templateUrl: 'partials/card/list.html'
      controller:  'CardListCtrl'
      name:        'card.list'
      resolve: {
        cards_default: (Card, $route) ->
          project_id = $route.current.params.project_id
          return Card.all({
            startkey: ["default", "#{project_id}."]
            endkey:   ["default", "#{project_id}.a"]
          })
        cards: (Card, $route) ->
          language   = window.navigator.language
          project_id = $route.current.params.project_id
          return Card.all({
            startkey: [language, "#{project_id}."]
            endkey:   [language, "#{project_id}.a"]
          })
        workflow: (Card, $route) ->
          project_id = $route.current.params.project_id
          return Card.view({
            view:     'workflow'
            startkey: "#{project_id}."
            endkey:   "#{project_id}.a"
          })
        project: (Project, $route) ->
          return Project.getDoc({
            id: $route.current.params.project_id
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
