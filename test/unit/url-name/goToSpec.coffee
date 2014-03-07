describe("GoTo Directive:", ->
  element = null
  $scope  = null

  beforeEach module('its')
  beforeEach inject ($rootScope, $compile, url) ->
    $scope = $rootScope
    element = angular.element('<a goto="test">link text</a>')
    spyOn(url, "getRouteByName").andReturn('/something')
    $compile(element, $scope)

)
