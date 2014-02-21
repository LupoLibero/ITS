ng.controller('ContainerCtrl', ($rootScope, $scope, notification, $translate, $location, url) ->
  $rootScope.url = url
  $scope.notif   = notification

  # Translate
  $translate.use(window.navigator.language)

  $rootScope.$on('$translateChangeError', () ->
    $translate.use('en')
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
