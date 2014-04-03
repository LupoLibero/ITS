/*
 * Usage: <script_name> http[s]://<username>:<password>@<serverUrl>
 * get list of daemons from kanso.json
 */

var cradle = require('cradle');
var path   = require('path');
var db;

if (process.argv[2]) {
  db = new(cradle.Connection)(process.argv[2]).database("_config");
  if (process.argv[3]) {
    db.get(process.argv[3], function (err, doc) {
      console.log(doc);
    });
  }
  else {
    db.query({
        method: 'PUT',
        path: 'os_daemons/role_setter',
        body: 'node ' + path.resolve(__dirname, 'modules/Login/role_setter.js'),
      },
      function (err, res) {
        console.log(err, res);
      }
    );
  }
}
