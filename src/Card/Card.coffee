angular.module('card').
factory('Card', (CouchDB, db)->
  return CouchDB(db.url, db.name, 'card')
)
