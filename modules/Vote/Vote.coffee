angular.module('vote').
factory('Vote', (CouchDB, db)->
  return CouchDB(db.url, db.name, 'vote')
)
