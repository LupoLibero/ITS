angular.module('subscription').
run( (notification, Subscription, $interval, login)->
  $interval( ->
    if login.isConnect()
      Subscription.view({
        view: 'short'

        startkey: ["", login.getName()]
        endkey:   [{}, login.getName()]
      }).then(
        (data) -> #Success
          console.log data
        ,(err) -> #Error
          console.log err
      )
    , 2000)
)
