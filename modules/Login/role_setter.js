var cradle = require('cradle');
var _      = require('underscore');
var Q      = require('q');

var db = new(cradle.Connection)('http://localhost', 5984, {
  cache: true,
  raw: false,
  forceSave: true
}).database('lupolibero');

var feed = db.changes({
  since: 42,
  filter: function (doc, req) {
    return doc.type == 'user'
  },
  include_docs: true
});

feed.on('change', function (change) {
  if (change.doc.email_validated) {
    console.log("\n", change.doc);
  }
});
