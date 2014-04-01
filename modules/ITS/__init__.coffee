angular.module('its', [
  'ngRoute'
  'dbSelect'
  'url'
  'navbar'
  'project'
  'ngCouchDB'
  'notification'
  'translation'
  'card'
  'mailer'
  'error'
  'ngStorage'
])

ng.value('db', {
  url: ''
  name:'its'
})
