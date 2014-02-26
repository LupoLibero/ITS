ng.controller('HistoryCtrl', ($scope, $route, Activity) ->
  $scope.histories = $route.current.locals.histories
)
