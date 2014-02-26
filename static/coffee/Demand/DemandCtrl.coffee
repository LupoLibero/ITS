ng.controller('DemandCtrl', ($scope, $route, Activity, $location) ->
  $scope.project     = $route.current.locals.project
  $scope.demand      = $route.current.locals.demand
  $scope.categories  = $route.current.locals.config[0].value
  $scope.resolutions = $route.current.locals.config[1].value
  $scope.statuses    = $route.current.locals.config[2].value

  if $route.current.params.onglet == 'history'
    $scope.historyTab = true
  else
    $scope.historyTab = false

  # History
  $scope.loadHistory = ->
    path = $location.path()
    $location.path(path+'/history')

  $scope.loadInformation = ->
    path = $location.path()
    path = path.split('/')
    path.pop()
    path = path.join('/')
    $location.path(path)
)
