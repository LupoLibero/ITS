config     = require('./config.json').smtp
nodemailer = require('nodemailer')
Q          = require('q')
User       = require('./Model/User')
smtpTransport = nodemailer.createTransport("SMTP", {
  host: config.host
  secureConnection: true
  port: config.port
  auth:
    user: config.user
    pass: config.password
})
sendMail   = Q.nbind(smtpTransport.sendMail, smtpTransport)

getMail = (data)->
  defer = Q.defer()
  emailObj = data[0]
  username = data[1]

  User.get(username).then(
    (data) -> #Success
      emailObj.to = data.email
      console.log emailObj
      defer.resolve(emailObj)
    ,(err) -> #Error
      defer.reject(err)
  )
  return defer.promise

module.exports = {
  send: (notification, username)=>
    defer = Q.defer()
    emailObj = {
      from:    "#{config.name} ✔ <#{config.email}>",
      subject: notification.subject
      text:    notification.message_txt
      html:    notification.message_html
    }
    getMail([emailObj, username])
      .then(sendMail)
      .then(
        (data)-> #Success
          defer.resolve(notification)
        ,(err)-> #Error
          defer.reject(err)
      )
    return defer.promise

}
