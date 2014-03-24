angular.module('card').
controller('CardCtrl', (parent, card, card_default, $scope, $route, $modalInstance, url, $q, Card) ->
  $scope.card = angular.extend(parent, card_default)
  $scope.card = angular.extend($scope.card, card[0])
)
