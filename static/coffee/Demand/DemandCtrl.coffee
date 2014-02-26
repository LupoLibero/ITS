ng.controller('DemandCtrl', ($scope, $route, Activity, $location) ->
  $scope.project     = $route.current.locals.project
  $scope.demand      = $route.current.locals.demand
  $scope.categories  = $route.current.locals.config[0].value
  $scope.resolutions = $route.current.locals.config[1].value
  $scope.statuses    = $route.current.locals.config[2].value

  # Tab System
  if not $location.search().hasOwnProperty('page')
    $location.search('page', 'information')

  $scope.tab = $location.search().page

  $scope.changeTo = (name) ->
    $location.search('page', name)
    $scope.tab = name

  # History
  $scope.loadHistory = ->
    if $scope.histories == undefined
      Activity.all({
        descending: true
        startkey: [demand._id,"\ufff0"]
        endkey: [demand._id,0]
      }).then(
        (data) -> #Success
          $scope.histories = data
          $location.search('page', 'history')
        ,(err) -> #Error
          $scope.notif.addAlert('Impossible to load history! Please try again', 'danger')
          if not $location.search().hasOwnProperty('page')
            $scope.$emit('SelectInformationTab')
      )
)
