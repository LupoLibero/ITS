excel  = require('excel-parser')
path   = require('path')
config = require('./config.json').sponsor
User   = require('./Model/User.coffee')
emails = []

excel.parse({
  inFile:    path.join(__dirname, config.email_filename)
  worksheet: config.worksheet
  skipEmpty: true
}, (err, records)->
  for record in records[0]
    User.view('email', {
      key: [record, false]
    }).then(
      (data)->
        if data.length > 0
          data = data[0].value
          User.addRole(data.name, 'sponsor')
      ,(err)->
        console.log err
    )
)
