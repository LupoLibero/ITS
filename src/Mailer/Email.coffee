angular.module('mailer').
factory('Email', (CouchDB, db)->
  return CouchDB(db.url, db.name, 'email')
)
