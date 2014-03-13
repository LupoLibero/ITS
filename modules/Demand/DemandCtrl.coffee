angular.module('demand').
controller('DemandCtrl', ($scope, $route, Activity, $location, Demand, $q, login) ->
  $scope.project     = $route.current.locals.project
  $scope.categories  = $route.current.locals.config[0].value
  $scope.statuses    = $route.current.locals.config[2].value

  # Pass the login factory to the view
  $scope.login = login

  # If a traduction is available
  if $route.current.locals.demand.length != 0
    $scope.demand = $route.current.locals.demand[0]
  else
    $scope.demand = $route.current.locals.demand_default

  # Languages
  $scope.actualLang = $scope.demand.lang
  $scope.available  = angular.copy($scope.demand.avail_langs)
  $scope.languages  = $route.current.locals.config[1].value

  $scope.$on('NewLanguage', ($event, key) ->
    $scope.$broadcast('EditFieldTranslationOn', key)
  )
  $scope.$on('ChangeLanguage', ($event, key) ->
    Demand.get({
      key: [$scope.demand.id, key]
    }).then(
      (data) -> #Success
        $scope.demand = data
    )
  )
  $scope.titleSave = ->
    $scope.change('title')
  $scope.descriptionSave = ->
    $scope.change('description')
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
    defer = $q.defer()
    $scope.startLoading(field)
    Demand.update({
      update:  'update_field'
      id:      $scope.demand.id
      element: field
      value:   $scope.demand[field]
      lang:    $scope.actualLang
      _rev:    $scope.demand._rev
    }).then(
      (data) -> #Success
        $scope.updated_at  = new Date().getTime()
        defer.resolve(data)
        $scope.endLoading(field)
        $route.current.locals.demand[field] = $scope.demand[field]
      ,(err) -> #Error
        console.log "Conflict"
        defer.reject(err)
        #TODO: popup confilct
    )
    return defer.promise

  $scope.startLoading = (field) ->
    $scope['load'+ field.substr(0,1).toUpperCase() + field.substr(1)] = true

  $scope.endLoading = (field) ->
    $scope['load'+ field.substr(0,1).toUpperCase() + field.substr(1)] = false
    $scope['load'+ field.substr(0,1).toUpperCase() + field.substr(1) + 'Finish'] = true

  # History
  if $route.current.params.onglet == 'history'
    $scope.historyTab = true
  else
    $scope.historyTab = false

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
