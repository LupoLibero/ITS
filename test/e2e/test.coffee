describe('First test', ->
  browser.get('.');
  it('should found signup', ->  
    text = $('.btn-primary').getText() 
    expect(text).toMatch('Sign Up')
  )
)
