angular.module('mailer').
run( ($rootScope, $location, Email, $localStorage)->

  _GET = $location.search()

  if _GET.hasOwnProperty('email_validation')
    $localStorage.email_validation = _GET.email_validation
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
  )
)
