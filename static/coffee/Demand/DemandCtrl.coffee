ng.controller('DemandCtrl', ($scope, $route, Activity, $location, Demand, $q) ->
  $scope.project     = $route.current.locals.project
  $scope.categories  = $route.current.locals.config[0].value
  $scope.statuses    = $route.current.locals.config[2].value

  # If a traduction is available
  if $route.current.locals.demand.length != 0
    $scope.demand = $route.current.locals.demand[0]
    $scope.save   = $route.current.locals.demand[0]
  else
    $scope.demand = $route.current.locals.demand_default
    $scope.save   = $route.current.locals.demand_default

  # Available language for this demand
  $scope.languages = angular.copy($scope.demand.avail_langs)
  # All lang available
  $scope.langs = $route.current.locals.config[1].value
  # Current lang
  $scope.actualLang = $scope.demand.lang

  $scope.$watch('actualLang', ->
    # If it's the actual lang don't do the rest
    if $scope.demand.lang == $scope.actualLang
      return false
    if $scope.demand.avail_langs.hasOwnProperty($scope.actualLang)
      return Demand.get({
        key: [$scope.save.id, $scope.actualLang]
      }).then(
        (data) -> #Success
          $scope.demand = data
          $scope.save   = data
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
    return Demand.update({
      update:  'update_field'
      id:      $scope.demand.id
      element: field
      value:   $scope.demand[field]
      lang:    $scope.demand.lang
      _rev:    $scope.demand._rev
    }).then(
      (data) -> #Success
        $scope.demand._rev = data.newrev
        defer.resolve(data)
        $scope.endLoading(field)
        $route.current.locals.demand[field] = $scope.demand[field]
      ,(err) -> #Error
        Activity.view({
          view: 'by_field'
          startkey:  [$scope.demand._id, field, $scope.demand.updated_at+1]
          endkey:    [$scope.demand._id, field, "\ufff0"]
        }).then(
          (data) -> #Success
            if data.length == 0
              Demand.get({
                id: $scope.demand.id
              }).then(
                (data) -> #Success
                  Demand.update({
                    update:  'update_field'
                    id:      $scope.demand.id
                    element: field
                    value:   $scope.demand[field]
                    lang:    $scope.demand.lang
                    _rev:    data._rev
                  }).then(
                    (data) -> #Success
                      console.log "done after conflict"
                  )
              )
            else
              console.log "Conflict"
              #TODO: popup confilct
        )
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
