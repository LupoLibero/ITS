ng.controller('ContainerCtrl', ($rootScope, $scope, notification, $translate, $location, url) ->
  # Some global definition because use everywhere
  $rootScope.url   = url
  $rootScope.notif = notification

  # Translate the interface in the language of the navigator
  $translate.use(window.navigator.language)

  # If the language doesn't exist on the database
  $rootScope.$on('$translateChangeError', () ->
    $translate.use('en') # Use English
    notification.addAlert("Your favorite language is not available. The content is displayed with the original language.")
  )

  # BreadCrumb
  $rootScope.$on('$routeChangeSuccess', ->
    path = $location.path()
    # Remove the hash if present
    path = path.replace('#', '')
    breadcrumb = path.split('/').splice(1)

    result = []
    link   = ''
    for piece in breadcrumb
      link += '/' + piece
      add=
        link: link
        value: piece
      result.push(add)

    $scope.breadcrumb = result
  )
)
