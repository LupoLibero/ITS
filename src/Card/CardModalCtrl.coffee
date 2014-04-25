angular.module('card').
controller('CardModalCtrl', ($scope, $state, $modal)->

  card_num = $state.params.card_num
  $modal.open({
    templateUrl: 'partials/card/show.html'
    controller:  'CardCtrl'
    keyboard:    false
    resolve: {
      card: ($q, $stateParams)->
        defer   = $q.defer()
        card_id = "#{$stateParams.project_id}.#{$stateParams.card_num}"

        for card in $scope.$parent.cards
          if card.id == card_id
            defer.resolve(card)

        defer.resolve()
        return defer.promise
    }
  }).result.then( (->), ->
    $state.go('^')
  )
)
