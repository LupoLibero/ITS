ng.factory('Project', (CouchDB, dbUrl)->
  return CouchDB(dbUrl, 'projects')
)
