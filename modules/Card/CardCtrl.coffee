angular.module('card').
controller('CardCtrl', (parent, card, card_default, $scope, $route, $modalInstance, url, $q, Card) ->
  $scope.card = angular.extend(parent, card_default)
  $scope.card = angular.extend($scope.card, card[0])

  $scope.close = ->
    url.redirect('card.list', {
      project_id: $route.current.locals.project.id
    })
    $modalInstance.close()

  $scope.saveTitle = ->
    return $scope.save('title')
  $scope.saveDescription = ->
    return $scope.save('description')

  $scope.save = (field) ->
    defer = $q.defer()
    Card.update({
      update:  'update_field'
      id:      $scope.card.id
      element: field
      value:   $scope.card[field]
      lang:    $scope.card.lang
      _rev:    $scope.card._rev
    }).then(
      (data) -> #Success
        defer.resolve(data)
      ,(err) -> #Success
        defer.reject(err)
    )
    return defer.promise
)
