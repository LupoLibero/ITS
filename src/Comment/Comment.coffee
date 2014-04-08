angular.module('comment').
factory('Comment', (CouchDB, db)->
  return CouchDB(db.url, db.name, 'comment')
)
