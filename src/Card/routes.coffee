angular.module('card').
config( ($stateProvider)->
  $stateProvider
    .state('card', {
      url:         '/project/:project_id',
      templateUrl: 'partials/card/list.html'
      controller:  'CardListCtrl'
      resolve: {
        project: (Project, $stateParams) ->
          return Project.getDoc({
            id: $stateParams.project_id
          })
        config: ($http, $q, db)->
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
    .state('card.show', {
      url:        '/{card_num:[0-9]+}{dash:\-?}{slug:.*}'
      controller: 'CardModalCtrl'
      template:   ''
    })
)
