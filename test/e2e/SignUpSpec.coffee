utils = require('./utils')

describe('SignUp:', ->
  browser.get('.')

  button   = $('.navbar-right .btn-primary')
  title    = $('.modal-header h3')
  pseudo   = $('#pseudo')
  mail     = $('#email')
  password = $('#password')
  passconf = $('#passwordconf')
  signup   = $('.modal-body .btn-primary')
  cancel   = $('.modal-body .btn-default')

  it('should found the signup button', ->
    expect(button.getText()).toMatch('Sign Up')
  )

  it('should display the signup popup', ->
    button.click()
    expect(title.getText()).toMatch('Sign Up')
  )

  it('should have signup form', ->
    expect(pseudo.isDisplayed()).toBeTruthy()
    expect(mail.isDisplayed()).toBeTruthy()
    expect(password.isDisplayed()).toBeTruthy()
    expect(passconf.isDisplayed()).toBeTruthy()
  )

  it('should have a signup and cancel button', ->
    expect(signup.isDisplayed()).toBeTruthy()
    expect(cancel.isDisplayed()).toBeTruthy()
  )

  # Check if the two buttons works
  it('should cancel the signup modal on click on the cancel button', ->
    cancel.click()
    $$('.modal-body').count().then(
      (count)->
        expect(count).toBe(0)
    )
  )

  it('should not accept two different password', ->
    button.click()
    pseudo.sendKeys(utils.getString())
    mail.sendKeys(utils.getString()+'@test.test')
    password.sendKeys(utils.getString())
    passconf.sendKeys(utils.getString())
    signup.click()
    expect(cancel.isDisplayed()).toBeTruthy()
  )

  it('should not accept a non valid email', ->
    name = utils.getString()
    pass = utils.getString()
    pseudo.clear()
    mail.clear()
    password.clear()
    passconf.clear()

    pseudo.sendKeys(name)
    mail.sendKeys(utils.getString())
    password.sendKeys(pass)
    passconf.sendKeys(pass)
    signup.click()
    expect(cancel.isDisplayed()).toBeTruthy()
  )
)
