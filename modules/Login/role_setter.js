var cradle = require('cradle');
var _      = require('underscore');
var Q      = require('q');
var dbCx, db, feed, dbGet;

function getConfig () {
  var deferred = Q.defer();
  require('properties').parse('modules/Notification/notification_creator.conf',
    {path: true, sections: true},
    function(error, config) {
      if (error) {
        console.error (error);
        return deferred.reject(error);
      }

      dbCx = new(cradle.Connection)(config.db.base_url, config.db.port, {
        cache: true,
        raw: false,
        forceSave: true,
        auth: { username: config.db.user, password: config.db.password }
      });
      db = dbCx.database(config.db.name);

      dbGet = Q.nbind(db.get, db);

      feed = db.changes({
        since: 42,
        filter: function (doc, req) {
          return doc.type == 'user'
        },
        include_docs: true
      });
      deferred.resolve();
    }
  );
  return deferred.promise;
}



function getAuthorizedUsers (field, docId) {

  }

function isAuthorized (p) {
  require('excel-parser').parse({
    inFile: config.main.email_filename,
    worksheet: 1,
    skipEmpty: true,
  }, function (err, records) {
    if(err) console.error(err);
    console.log(worksheets);
  });
}

function hasRole (p) {
  var deferred = Q.defer();
  dbCx.database('_users').get('org.couchdb.user:' + p.user, function (err, doc) {
    if(err) {
      console.log(err, p);
      deferred.reject(p);
      return
    }
    if (_.include(doc.roles, p.role))
      deferred.resolve(p);
    else
      deferred.reject(p);
  });
  return deferred.promise;
}

function addRole (p) {

}

getConfig().done(function () {
  console.log("start");
  feed.on('change', function (change) {
    if (change.doc.email_validated) {
      console.log("\n", change.doc);
      hasRole({user: change.doc.id, role: 'sponsor'}).then(isAuthorized).then(addRole);
    }
  });
});
