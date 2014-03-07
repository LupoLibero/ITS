describe("DemandCtrl:", ->
  controller = null
  beforeEach module('its')
  beforeEach inject ($controller) ->
    controller = $controller('DemandCtrl')
)
