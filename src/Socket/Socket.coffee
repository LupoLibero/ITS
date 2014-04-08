angular.module('socket').
factory('socket', ($location) ->
  host = $location.host()
  return io.connect("//#{host}:8800")
)
