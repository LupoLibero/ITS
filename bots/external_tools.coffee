###
 # Usage: <script_name> http[s]://<username>:<password>@<serverUrl>
 #           OR
 # Usage: <script_name> default|production (taken from .kansorc)
 # get list of daemons from kanso.json
###

cradle  = require('cradle')
path    = require('path')
fs      = require('fs')
bots    = require('../kanso.json').bots
db      = null
address = null
kansorc = null
name    = null

if fs.existsSync('.kansorc')
  kansorc = require('../.kansorc').env

if process.argv[2]
  if process.argv[2].match(/^http(?:s)?:\/\//)
    address = process.argv[2]
  else
    if kansorc
      name = process.argv[2]
      if kansorc[name]?.db?
        address = kansorc[name].db
      else
        throw new Error("#{name}: Not found in .kansorc or has not the property 'db'")
    else
      throw new Error('No .kansorc found')

  # get the address without the database name
  address = address.match(/^http(?:s)?:\/\/.*\//)[0]
  # remove the last slash don't work otherwise
  address = address.substr(0, address.length-1)

  console.log "Installation of bots in " + address.replace(/\/\/.*@/, '\/\/') + "/_config db"

  db = new(cradle.Connection)(address).database("_config")
  for bot in bots
    filepath = path.resolve(bot)
    name     = path.basename(filepath).split('.')[0]
    ( (name)->
      return db.query({
          method: 'PUT'
          path: "os_daemons/#{name}"
          body: filepath
        }, (err, res)->
          if err
            console.log("#{name}: ERROR")
            console.log(err)
          else
            console.log("#{name}: INSTALLED")
      )
    )(name)
else
  console.log('An argument is needed')
