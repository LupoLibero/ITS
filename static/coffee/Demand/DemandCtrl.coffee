ng.controller('DemandCtrl', ($scope, $route, Activity, $location, Demand) ->
  $scope.project     = $route.current.locals.project
  $scope.categories  = $route.current.locals.config[0].value
  $scope.statuses    = $route.current.locals.config[1].value

  # If a traduction is available
  if $route.current.locals.demand.length != 0
    $scope.demand = $route.current.locals.demand[0]
    $scope.save   = $route.current.locals.demand[0]
  else
    $scope.demand = $route.current.locals.demand_default
    $scope.save   = $route.current.locals.demand_default

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

  # On change
  $scope.change = (field) ->
    $scope.startLoading(field)
    Demand.update({
      update:  'update_field'
      id:      $scope.demand.id
      element: field
      value:   $scope.demand[field]
      lang:    $scope.demand.lang
      _rev:    $scope.demand._rev
    }).then(
      (data) -> #Success
        $scope.endLoading(field)
        $route.current.locals.demand[field] = $scope.demand[field]
    )

  $scope.startLoading = (field) ->
    $scope['load'+ field.substr(0,1).toUpperCase() + field.substr(1)] = true

  $scope.endLoading = (field) ->
    $scope['load'+ field.substr(0,1).toUpperCase() + field.substr(1)] = false
    $scope['load'+ field.substr(0,1).toUpperCase() + field.substr(1) + 'Finish'] = true
    $scope[field + 'HasChange'] = false

  # Title
  $scope.titleHasChange = false
  $scope.titleChange = ->
    $scope.titleHasChange = true

  $scope.titleSave = ->
    $scope.change('title')

  $scope.titleCancel = ->
    $scope.demand.title = $scope.save.title
    $scope.titleHasChange = false

  # Description
  $scope.descriptionHasChange = false
  $scope.descriptionChange = ->
    $scope.descriptionHasChange = true

  $scope.descriptionSave = ->
    $scope.change('description')

  $scope.descriptionCancel = ->
    $scope.demand.description = $scope.save.description
    $scope.descriptionHasChange = false

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
