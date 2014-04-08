angular.module('project').
factory('Project', (CouchDB, db) ->
  return CouchDB(db.url, db.name, 'project')
)
