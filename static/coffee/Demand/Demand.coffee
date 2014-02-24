ng.factory('Demand', (CouchDB, dbUrl, name)->
  return CouchDB(dbUrl, name, 'demand')
)
