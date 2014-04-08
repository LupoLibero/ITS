angular.module('its').
config( ($routeProvider)->
  # $locationProvider.html5Mode(true)
  $routeProvider
    .otherwise({redirectTo: '/project'})
)
