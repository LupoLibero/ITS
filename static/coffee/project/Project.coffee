ng.factory('Project', (CouchDB, dbUrl, name)->
  return CouchDB(dbUrl, name, 'project')
)
