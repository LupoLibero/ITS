angular.module('card').
controller('CardCtrl', ($scope, $route) ->
  $scope.card = angular.extend($route.current.locals.card_default.cards[0], $route.current.locals.card[0].cards[0])
)
