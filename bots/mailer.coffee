Notification  = require('./Model/Notification')
Mail          = require('./Mail')

# setInterval(->
Notification.all().then(
  (data)-> #Success
    data.forEach (notification)->
      Mail.send(notification, notification.subscriber)
        .then(Notification.hasBeenSend)
        .then(
          (data)-> #Success
            console.log('Mail Send')
          ,(err)-> #Error
            console.log(error)
        )
  ,(err)-> #Success
    console.log(err)
)
# ,1000 * 60 * 5)
