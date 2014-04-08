angular.module('its').
filter('default', () ->
  return (value, param) ->
    if value is undefined or value == null or value is ''
      return param
    else
      return value
)
