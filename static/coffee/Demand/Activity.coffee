ng.factory('Activity', (CouchDB, dbUrl, name)->
  return CouchDB(dbUrl, name, 'activity')
)
