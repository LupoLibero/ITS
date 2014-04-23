angular.module('card').
controller('CardModalCtrl', ($scope, $state, $modal)->

  card_num = $state.params.card_num
  $modal.open({
    templateUrl: 'partials/card/show.html'
    controller:  'CardCtrl'
    keyboard:    false
    resolve: {
      card: ($q, $stateParams)->
        defer = $q.defer()
        found = false

        for card in $scope.$parent.cards
          if card.num == $stateParams.card_num
            defer.resolve(card)
            break

        defer.reject() if not found
        return defer.promise
    }
  }).result.then( (->), ->
    $state.go('^')
  )
)
