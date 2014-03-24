angular.module('its', [
  'ngRoute'
  'dbSelect'
  'url'
  'pascalprecht.translate'
  'navbar'
  'project'
  'ngCouchDB'
  'notification'
  'translation'
  'card'
  'mailer'
  'ngStorage'
])

ng.value('db', {
  url: ''
  name:'its'
})
