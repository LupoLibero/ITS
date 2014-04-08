angular.module('its').
controller('ContainerCtrl', ($scope, $rootScope, notification, Local) ->
  $scope.loader = true

  $rootScope.saveTranslation = (key, text, lang) ->
    Local.update({
      update: 'update'
      id: lang

      key:  key
      text: text
    })

  $rootScope.$on('LangBarChangeLanguage', ($event, lang) ->
    $rootScope.$broadcast('$ChangeLanguage', lang)
  )

  # Change for language of the navigator
  $rootScope.$broadcast('$ChangeLanguage', window.navigator.language)
  # On error change for english and display an message
  $rootScope.$on('$translateChangeError', ($event, lang)->
    if lang isnt 'en'
      $rootScope.$broadcast('$ChangeLanguage', 'en')
      notification.addAlert("You're favorite language is not available!", 'warning')
  )

  $rootScope.$on('$routeChangeStart', (event, err) ->
    $rootScope.$broadcast('LoadingStart')
  )
  $rootScope.$on('$routeChangeSuccess', (event, err) ->
    $rootScope.$broadcast('LoadingEnd')
  )
  $rootScope.$on('$routeChangeError', (event, err) ->
    console.log "$routeChangeError", event, err
  )

  # Loader
  $rootScope.$on('LoadingStart', ->
    $scope.loader = true
  )
  $rootScope.$on('LoadingEnd', ->
    $scope.loader = false
  )
)
