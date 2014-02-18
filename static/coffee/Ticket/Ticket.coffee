ng.factory('Ticket', (CouchDB, dbUrl, name)->
  return CouchDB(dbUrl, name, 'ticket')
)
