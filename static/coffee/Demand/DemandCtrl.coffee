ng.controller('DemandCtrl', ($scope, $route, Activity, $location, $http, dbUrl, name) ->
  $scope.project     = $route.current.locals.project
  $scope.demand      = $route.current.locals.demand
  $scope.categories  = $route.current.locals.config[0].value
  $scope.resolutions = $route.current.locals.config[1].value
  $scope.statuses    = $route.current.locals.config[2].value

  # Spinner
  $scope.littleSpinner= {radius:4, width:3, length:5, lines:9}
  $scope.bigSpinner= {radius:6, width:3, length:5, lines:11}

  # Category
  $scope.loadCategory = false
  $scope.loadCategoryFinish = false
  $scope.categoryChange = ->
    $scope.change('category')

  # Status
  $scope.loadStatus = false
  $scope.loadStatusFinish = false
  $scope.statusChange = ->
    $scope.change('status')

  # Resolution
  $scope.loadResolution = false
  $scope.loadResolutionFinish = false
  $scope.resolutionChange = ->
    $scope.change('resolution')

  $scope.change = (field) ->
    $scope.startLoading(field)
    id = $scope.demand._id.replace('#', '%23')
    $http.put("#{dbUrl}/_design/#{name}/_update/demand_update_field/#{id}", {
      element: field
      value:   $scope.demand[field]
      _rev:    $scope.demand._rev
    }).then(
      (data) -> #Success
        $scope.endLoading(field)
      ,(err) -> #Error
        console.log "error"
    )

  $scope.startLoading = (field) ->
    $scope['load'+ field.substr(0,1).toUpperCase() + field.substr(1)] = true

  $scope.endLoading = (field) ->
    $scope['load'+ field.substr(0,1).toUpperCase() + field.substr(1)] = false
    $scope['load'+ field.substr(0,1).toUpperCase() + field.substr(1) + 'Finish'] = true


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
