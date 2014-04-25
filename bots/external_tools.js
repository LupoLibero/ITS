/*
 * Usage: <script_name> http[s]://<username>:<password>@<serverUrl>
 *            OR
 * Usage: <script_name> default|production (taken from .kansorc)
 * get list of daemons from kanso.json
 */

var cradle = require('cradle');
var path   = require('path');
var fs     = require('fs');
var bots   = require('../kanso.json').bots;
var db;

if( fs.existsSync('.kansorc') ) {
  var rc = require('../.kansorc').env;
}

if (process.argv[2]) {

  if (process.argv[2].match(/^http(?:s)?:\/\//)) {
    adress = process.argv[2]
  } else {
    if(rc) {
      name = process.argv[2]
      if( rc.hasOwnProperty(name) && rc[name].hasOwnProperty('db')) {
        adress = rc[name].db;
        // get the adress without the database name
        adress = adress.match(/^http(?:s)?:\/\/.*\//)[0];
        // remove the last slash don't work otherwise
        adress = adress.substr(0, adress.length-1);
      } else {
        throw new Error(name+': Not found in .kansorc or haven\'t the property db');
      }
    } else {
      throw new Error('No .kansorc found');
    }
  }

  db = new(cradle.Connection)(adress).database("_config");
  if (process.argv[3]) {
    db.get(process.argv[3], function (err, doc) {
      console.log(doc);
    });
  }
  else {
    for(i in bots){
      filepath = path.resolve(bots[i]);
      name     = path.basename(filepath).split('.')[0]
      db.query({
          method: 'PUT',
          path: 'os_daemons/' + name,
          body: 'node ' + filepath
        },
        function (err, res) {
          console.log(err, res);
        }
      );
    }
  }
}
