describe("Capitalize filter:", ->
  beforeEach module('its')

  it("should capitalize a word", inject ($filter) ->
    expect($filter('capitalize')('text')).toEqual('Text')
    expect($filter('capitalize')('foo')).toEqual('Foo')
  )

  it("should capitalize a string", inject ($filter) ->
    expect($filter('capitalize')('i test')).toEqual('I Test')
    expect($filter('capitalize')('foo bar')).toEqual('Foo Bar')
  )

  it("should not capitalize when it's not a string", inject ($filter) ->
    expect($filter('capitalize')({})).toEqual({})
    expect($filter('capitalize')(1)).toEqual(1)
  )
)
