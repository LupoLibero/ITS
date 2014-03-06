describe('SignUp:', ->
  browser.get('.')

  button   = $('.btn-primary')
  title    = $('.modal-header>h3')
  pseudo   = $('#pseudo')
  password = $('#password')
  passconf = $('#passwordconf')
  signup   = $('.modal-body>.btn-primary')
  cancel   = $('.modal-body>.btn-default')

  it('should found the signup button', ->
    expect(button.getText()).toMatch('Sign Up')
  )

  # Check if the modal is good
  it('should display the signup popup', ->
    button.click()
    expect(title.getText()).toMatch('Sign Up')
  )

  it('should have signup form', ->
    expect(pseudo.isDisplayed()).toBeTruthy()
    expect(password.isDisplayed()).toBeTruthy()
    expect(passconf.isDisplayed()).toBeTruthy()
  )

  it('should have a signup and cancel button', ->
    expect(signup.isDisplayed()).toBeTruthy()
    expect(cancel.isDisplayed()).toBeTruthy()
  )

  # Check if the two buttons works
  it('should cancel the signup modal on click on the cancel button', ->
    button.click()
    cancel.click()
    expect(title.isDisplayed()).toBeFalsy()
  )

  it('should signup on click on the signup button', ->
  )
)
