angular.module('error').
run( ($rootScope, notification, Local)->
  $rootScope.$on('DatabaseError', ($event, error)->
    message = null
    console.log error
    if not error.status || error.status == 500
      error = error.reason.replace(/.*{forbidden:"(.*)"}.*\n?.*/gm, '$1')
    else
      if error.data?.hasOwnProperty('reason')
        error = error.data.reason

    error = (if isNaN(parseInt(error)) then error else parseInt(error))

    message = switch error
      when 1 then 'Conflict: Already modify'

    if message?
      notification.addAlert(message, 'danger')
 )
)
