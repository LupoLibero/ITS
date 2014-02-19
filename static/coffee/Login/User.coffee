ng.factory('User', (CouchDB, dbUrl, name)->
  return CouchDB(dbUrl, name, 'user')
)
