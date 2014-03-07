describe('Default filter:', ->
  beforeEach module('its')

  it('should complete with his value when the text is empty', inject ($filter) ->
    expect($filter('default')('', 'incre')).toEqual('incre')
    expect($filter('default')('', 'nausie')).toEqual('nausie')
  )

  it('should not complete with his value when the text is not empty', inject ($filter) ->
    expect($filter('default')('text', 'incre')).toEqual('text')
    expect($filter('default')('another', 'nausie')).toEqual('another')
  )
)
