angular.module('its').
controller('ContainerCtrl', ($scope, $rootScope, notification, $translate, $location, Email, $localStorage) ->
  $rootScope.notif = notification
  $scope.loader = true

  if $location.search().hasOwnProperty('email_validation')
    $localStorage.email_validation = $location.search().email_validation
    $location.url($location.path())

  $rootScope.$on('SessionStart', ($event, username)->
    if $localStorage.email_validation?
      if username == ''
        notification.addAlert('Please connect for completed the validation of your email', 'info')
      else
        email_validation = $localStorage.email_validation
        delete $localStorage.email_validation

        $rootScope.$broadcast('LoadingStart')
        Email.update({
          update: 'validation'
          _id:    "user-#{username}"
          token:  email_validation
        }).then(
          (data) -> #Success
            $rootScope.$broadcast('LoadingEnd')
            notification.addAlert('Your email has been validate', 'success')
          ,(err) -> #Error
            $rootScope.$broadcast('LoadingEnd')
            notification.addAlert('Your email has not been validate', 'danger')
        )
    else
      $rootScope.$broadcast('LoadingEnd')
  )

  $translate.use(window.navigator.language)
  $rootScope.$on('$translateChangeError', ->
    $translate.use('en')
    notification.addAlert("You're favorite language is not available!", 'warning')
  )

  $rootScope.$on('DatabaseError', (event, err) ->
    if err.reason == 'You must be logged in'
      notification.addAlert('You need to be connected!', 'danger')
    else
      console.log "DatabaseError", event, err
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

  $rootScope.$on('LoadingStart', ->
    $scope.loader = true
  )
  $rootScope.$on('LoadingEnd', ->
    $scope.loader = false
  )
)
