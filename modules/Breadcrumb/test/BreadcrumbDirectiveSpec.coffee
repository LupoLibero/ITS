describe("Breadcrumb Directive:", ->
  element   = null
  $location = null
  $scope    = null

  beforeEach module('its')
  beforeEach inject ($compile, $rootScope, _$location_) ->
    $scope    = $rootScope
    element   = angular.element('<breadcrumb></breadcrumb>')
    $location = _$location_
    $compile(element, $scope)

  # it("should change at every new route", ->
  #   spyOn($location, "path")
  #   $scope.$broadcast('$routeChangeSuccess')
  #   expect($location.path).toHaveBeenCalled()
  # )
)
