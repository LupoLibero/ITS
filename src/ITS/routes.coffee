angular.module('its').
config( ($urlRouterProvider)->
  # $locationProvider.html5Mode(true)
  $urlRouterProvider
    .otherwise('/project')
)
