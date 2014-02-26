ng.factory('Comment', (CouchDB, dbUrl, name)->
  return CouchDB(dbUrl, name, 'comment')
)
