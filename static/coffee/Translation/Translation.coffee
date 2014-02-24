ng.factory('translation', ($q, $http, dbUrl)->
  return (options) ->
    defer = $q.defer()
    $http.get(dbUrl + '/local-' + options.key).then(
      (data) -> # Success
        data = data.data
        delete data._id
        delete data._rev
        defer.resolve(data)
      ,(err) -> # Error
        if options.key == 'en'
          defer.resolve({})
        defer.reject(err)
    )
    return defer.promise
)
