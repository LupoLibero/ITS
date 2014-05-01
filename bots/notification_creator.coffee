Q            = require('q')
db           = require('./db')()
users        = require('./db')('_users')
crypto       = require('crypto')
Subscription = require('./Model/Subscription')
User         = require('./Model/User')
Notification = require('./Model/Notification')

monitoredTypes = {
  card: {
    name: 'card'
    key:  '_id'
    templates:
      subject:      'hello {{subscriber}}'
      message_txt:  'This is a test'
      message_html: '<h1>This is a test</h1>'
    notification_type: 'email'
    monitoring_type:   'subscription'
  },
  user: {
    name: 'user'
    key: '_id'
    preprocessors: ['buildValidationUrl']
    templates:
      subject: 'Email validation {{subscriber}}'
      message_txt:  'Validation url: {{validationUrl}}'
      message_html: '<p>Validation url: <a href="{{validationUrl}}">{{validationUrl}}</a>'
    notification_type: 'email'
    monitoring_type: 'to-user'
  }
}

createToken = (template)->
  defer = Q.defer()
  crypto.randomBytes 10, (ex, buf)->
    token     = buf.toString('hex')
    shasum    = crypto.createHash('md5')
    shasum.update(token)
    token_md5 = shasum.digest('hex')
    console.log(token, token_md5)
    link = "http://localhost:5984/lupolibero/_design/its/_rewrite/#email_validation?token=#{token}"
    template.message_text.replace('{{validationUrl}}', link)
    template.message_html.replace('{{validationUrl}}', link)
    template.subject.replace('{{subscriber}}', template.subscriber)
    template.token = token_md5
    defer.resolve(template)
  return defer.promise

db.changes({
  include_docs: true
  since: "now"
}).on('change', (change)->
  doc  = change.doc
  id   = doc._id
  type = doc.type
  rev  = parseInt(doc._rev)
  if monitoredTypes.hasOwnProperty(type)
    console.log "change on #{id}"
    type = monitoredTypes[type]
    if type.monitoring_type == 'subscription'
      console.log "subscription type"
      Subscription.get(id).then(
        (data)-> #Success
          console.log "#{data.length} subscription found"
          data.forEach (row)->
            template            = type.templates
            template.subscriber = row.subscriber
            template.id         = "#{change.seq}-#{row.subscriber}"

            Notification.create(template).then(
              (data)->
                console.log('notification create')
              (err)->
                console.log(err)
            )
        ,(err)-> #Errorr
          console.log err
      )
)

users.changes({
  include_docs: true
}).on('change', (change)->
  doc  = change.doc
  rev  = parseInt(doc._rev)
  type = monitoredTypes['user']
  if rev == 1
    console.log "User create"

    template            = type.templates
    template.subscriber = doc.name
    template.id         = "#{change._seq}-#{doc.name}"

    createToken(template)
      .then(User.saveToken)
      .then(Notification.create)
      .then(
        (data)-> #Success
          console.log data
        ,(err)-> #Error
          console.log err
      )
)
