var path   = require('path');
var cradle = require('cradle');
var _      = require('underscore');
var Q      = require('q');
var config, dbCx, db, feed, dbGet;

function getConfig () {
  var deferred = Q.defer();
  require('properties').parse(path.join(__dirname, 'role_setter.conf'),
    {path: true, sections: true},
    function(error, obj) {
      if (error) {
        console.error (error);
        return deferred.reject(error);
      }
      config = obj;

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
  var deferred = Q.defer();
  console.log('isAuthorized');
  require('excel-parser').parse({
    inFile: path.join(__dirname, config.main.email_filename),
    worksheet: config.main.worksheet,
    skipEmpty: true,
    //searchFor: {
    //  term: [config.main.search_term],
    //  type: 'loose'
    //}
  }, function (err, records) {
    var email_list;
    if(err) {
      console.error(err);
      deferred.reject(err);
    }
    email_list = Array.prototype.concat.apply([], records);
    console.log(email_list, p.user.email);
    if (_.include(email_list, p.user.email)) {
      deferred.resolve(p);
    }
    else {
      deferred.reject(p);
    }
  });
  return deferred.promise;
}

function hasNotYetRole (p) {
  var deferred = Q.defer();
  dbCx.database('_users').get('org.couchdb.user:' + p.user.name, function (err, doc) {
    if(err) {
      console.log(err, p);
      deferred.reject(p);
    }
    else {
      console.log(doc);
      p.user.roles = doc.roles;
      if (!_.include(doc.roles, p.role)) {
        console.log("does not have role");
        deferred.resolve(p);
      }
      else
        deferred.reject(p);
    }
  });
  return deferred.promise;
}

function addRole (p) {
  console.log("addRole");
  p.user.roles.push(p.role);
  dbCx.database('_users').merge('org.couchdb.user:' + p.user.name,
    {roles: p.user.roles},
    function (err, res) {
      console.log(err, res)
    }
  );
}

getConfig().done(function () {
  console.log("start");
  feed.on('change', function (change) {
    if (change.doc.email_validated) {
      console.log("\n", change.doc);
      hasNotYetRole({user: change.doc, role: 'sponsor'}).then(isAuthorized).then(addRole);
    }
  });
});
