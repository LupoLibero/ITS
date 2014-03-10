angular.module('dbSelect').
run( ($location, db) ->
  if $location.absUrl().indexOf('_rewrite')
    db.url = '/' + $location.absUrl().split('/')[3]
  else
    # vhost
    # host: dev.lupolibero.org -> db: /lupolibero-dev
    db.url = '/lupolibero-' + $location.host().split('.')[0]
)
