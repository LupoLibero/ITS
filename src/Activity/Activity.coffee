angular.module('activity').
factory('Activity', (CouchDB, db)->
  return CouchDB(db.url, db.name, 'activity')
)