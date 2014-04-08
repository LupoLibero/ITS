describe('ActualLink Directive:', ->
  element   = null
  $scope    = null
  $location = null

  beforeEach(module('its'))
  beforeEach inject ($compile, _$rootScope_, _$location_) ->
    $scope    = _$rootScope_
    $location = _$location_
    element   = angular.element('<li actual-link><a href = "#/test">Test</a></li>')
    $compile(element)($scope)

  it("should be activate when the href is equals to actual path", ->
    spyOn($location, "path").andReturn('/test')
    $scope.$broadcast('$routeChangeSuccess')
    expect(element.hasClass('active')).toBeTruthy()
  )

  it("should be not activate when the href is not equals to actual path", ->
    spyOn($location, "path").andReturn('/uienstuinret')
    $scope.$broadcast('$routeChangeSuccess')
    expect(element.hasClass('active')).toBeFalsy()
  )
)
