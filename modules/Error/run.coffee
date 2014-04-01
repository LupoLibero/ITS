angular.module('error').
run( ($rootScope, notification)->
  $rootScope.$on('DatabaseError', ($event, error)->
    message = null
    if not error.status || error.status == 500
      error = error.reason.replace(/.*{forbidden:"(.*)"}.*\n?.*/gm, '$1')
      error = parseInt(error)
    else
      error = parseInt(error.data.reason)

    message = switch error
      when 001 then 'Conflict: Already modify'

    if message?
      notification.addAlert(message, 'danger')
 )
)
