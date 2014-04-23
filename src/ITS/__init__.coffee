angular.module('its', [
  'ui.router'
  'dbSelect'
  'navbar'
  'project'
  'ngCouchDB'
  'notification'
  'translation'
  'card'
  'mailer'
  'error'
  'socket'
  'ngStorage'
  'markdown'
])

ng.value('db', {
  url: ''
  name:'its'
})
