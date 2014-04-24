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
        for card in $scope.$parent.cards
          if card.id == $stateParams.card_num
            defer.resolve(card)
        defer.resolve({})
        return defer.resolve()
    }
  }).result.then( (->), ->
    $state.go('^')
  )
)
