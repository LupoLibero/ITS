angular.module('login').
factory('User', (CouchDB, db)->
  return CouchDB(db.url, db.name, 'user')
)
