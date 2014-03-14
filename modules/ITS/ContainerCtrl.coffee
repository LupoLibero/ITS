angular.module('its').
controller('ContainerCtrl', ($rootScope, notification, $translate, $location, Email, login) ->
  # Some global definition because use everywhere
  $rootScope.notif = notification

  # Check if the user wants to validate is email adress
  $rootScope.$on('SignIn', ->
    if $location.search().hasOwnProperty('email_validation')
    $rootScope.$broadcast('Loading')
    Email.update({
      update: 'validation'
      _id:    "user-#{login.getName()}"
      token:  $location.search().email_validation
    }).then(
      (data) -> #Success
      $rootScope.$broadcast('endLoading')
      notification.addAlert('Your email has been validate', 'success')
      $location.url($location.path())
      ,(err) -> #Error
      $rootScope.$broadcast('endLoading')
      notification.addAlert('Your email has not been validate', 'danger')
      $location.url($location.path())
    )
  )

  # Translate the interface in the language of the navigator
  $translate.use(window.navigator.language)

  # If the language doesn't exist on the database
  $rootScope.$on('$translateChangeError', () ->
    $translate.use('en') # Use English
    notification.addAlert("Your favorite language is not available. The content is displayed with the original language.")
  )

  $rootScope.$on('DatabaseError', (event, err) ->
    console.log "DatabaseError", event, err
  )

  $rootScope.$on('$routeChangeError', (event, err) ->
    console.log "$routeChangeError", event, err
  )
)
