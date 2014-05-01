excel  = require('excel-parser')
path   = require('path')
fs     = require('fs')
config = require('./config.json').sponsor
emails = []

excel.parse({
  inFile:    path.join(__dirname, config.email_filename)
  worksheet: config.worksheet
  skipEmpty: true
}, (err, records)->
  console.log records
)
