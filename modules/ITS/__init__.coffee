angular.module('its', [
  'ngRoute'
  'dbSelect'
  'url'
  'breadcrumb'
  'pascalprecht.translate'
  'navbar'
  'project'
  'ngCouchDB'
  'notification'
  'translation'
  'demand'
  'mailer'
  'ngStorage'
])

ng.value('db', {
  url: ''
  name:'its'
})
