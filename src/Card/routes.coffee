angular.module('card').
config( ($routeProvider)->
  $routeProvider
    .when('/project/:project_id/:card_num?', {
      templateUrl: 'partials/card/list.html'
      controller:  'CardListCtrl'
      name:        'card.list'
      resolve: {
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
