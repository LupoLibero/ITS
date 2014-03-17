angular.module('its').
controller('ContainerCtrl', ($rootScope, notification, $translate, $location, Email, $localStorage) ->
  $rootScope.notif = notification

  # Check if the user wants to validate is email adress
  if $location.search().hasOwnProperty('email_validation')
    $localStorage.email_validation = $location.search().email_validation
    $location.url($location.path())

  # If the user is not connect and have a validation in storage
  $rootScope.$on('SessionStart', ($event, username)->
    if $localStorage.email_validation?
      if username == ''
        notification.addAlert('Please connect for completed the validation of your email', 'info')
      else
        # remove the validation from storage for preventing problem
        email_validation = $localStorage.email_validation
        delete $localStorage.email_validation

        $rootScope.$broadcast('Loading')
        Email.update({
          update: 'validation'
          _id:    "user-#{username}"
          token:  email_validation
        }).then(
          (data) -> #Success
            $rootScope.$broadcast('endLoading')
            notification.addAlert('Your email has been validate', 'success')
          ,(err) -> #Error
            $rootScope.$broadcast('endLoading')
            notification.addAlert('Your email has not been validate', 'danger')
        )
  )

  # Translate the interface in the language of the navigator
  $translate.use(window.navigator.language)

  # If the language doesn't exist on the database
  $rootScope.$on('$translateChangeError', ->
    $translate.use('en') # Use English
  )

  $rootScope.$on('DatabaseError', (event, err) ->
    console.log "DatabaseError", event, err
  )

  $rootScope.$on('$routeChangeError', (event, err) ->
    console.log "$routeChangeError", event, err
  )
)
