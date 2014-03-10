angular.module('forum').
factory('Forum', (CouchDB, db) ->
  return CouchDB(db.url, db.name, 'forum')
)
