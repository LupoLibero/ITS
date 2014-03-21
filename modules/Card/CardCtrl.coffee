angular.module('card').
controller('CardCtrl', ($scope, $route, Activity, $location, Card, $q, login, url) ->
  $scope.project     = $route.current.locals.project
  $scope.categories  = $route.current.locals.config[0].value
  $scope.statuses    = $route.current.locals.config[2].value

  # Pass the login factory to the view (I need it for checking the role)
  $scope.login = login

  # If a traduction is available
  if $route.current.locals.card.length != 0
    $scope.card = $route.current.locals.card[0]
  else
    $scope.card = $route.current.locals.card_default

  # Languages
  $scope.actualLang = $scope.card.lang
  $scope.available  = angular.copy($scope.card.avail_langs)
  $scope.languages  = $route.current.locals.config[1].value

  # On select new language in the langbar
  $scope.$on('NewLanguage', ($event, key) ->
    $scope.actualLang = key
    $scope.$broadcast('EditFieldTranslationOn', key)
  )

  # When the user change language in the langbar
  $scope.$on('ChangeLanguage', ($event, key) ->
    $scope.actualLang = key

    Card.get({
      key: [$scope.card.id, key]
    }).then(
      (data) -> #Success
        $scope.$broadcast('EditFieldChangeLanguage', key)
        $scope.card = data
      ,(err) -> #Error
        $scope.$broadcast('EditFieldTranslationOn', key)
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
    Card.update({
      update:  'update_field'
      id:      $scope.card.id
      element: field
      value:   $scope.card[field]
      lang:    $scope.actualLang
      _rev:    $scope.card._rev
    }).then(
      (data) -> #Success
        $scope.updated_at  = new Date().getTime()
        defer.resolve(data)
        $scope.endLoading(field)
        $route.current.locals.card[field] = $scope.card[field]
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
  $scope.historyTab = $route.current.params.onglet == 'history'

  $scope.loadInformation = ->
    url.redirect('card.show', {
      project_id: $scope.project.id
      card_id:    $scope.card.id
    })

  $scope.loadHistory = ->
    url.redirect('card.show', {
      project_id: $scope.project.id
      card_id:    $scope.card.id
      onglet:     'history'
    })
)
