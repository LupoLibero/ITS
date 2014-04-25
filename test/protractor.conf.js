require('coffee-script').register()

exports.config = {
  seleniumAddress: 'http://localhost:4444/wd/hub',
  capabilities: {
    'browserName': 'firefox'
  },
  baseUrl: 'http://localhost:5984/lupolibero/_design/its/_rewrite/',
  specs: ['e2e/*.coffee']
}
