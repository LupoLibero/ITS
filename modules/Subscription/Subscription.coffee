angular.module('subscription').
factory('Subscription', (CouchDB, db)->
  return CouchDB(db.url, db.name, 'subscription')
)
