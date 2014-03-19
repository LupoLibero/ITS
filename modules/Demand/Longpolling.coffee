angular.module('demand').
factory('longPolling', (db, $http, $rootScope, $q) ->
  return {
    filter: ''
    setFilter: (filter) ->
      this.filter = filter

    start: ->
      @changes()

    changes: (last = "now") ->
      _this = this
      url   = "#{db.url}/_changes?feed=longpoll&filter=#{@filter}&since=#{last}"

      $http.get(url, {
        timeout: () ->
          defer = $q.defer()
          $rootScope.$on('$routeChangeSuccess', ->
            defer.resolve("end")
          )
          return defer.promise

      }).then(
        (data) -> #Success
          last = data.data.last_seq

          if typeof data.data.results == 'object'
            for change in data.data.results
              type = change.id.split('-')[0]

              # foo_bar -> FooBar
              # test    -> Test
              type = type.split('_')
              for piece, i in type
                type[i] = type[i][0].toUpperCase() + type[i][1..-1].toLowerCase()
              type = type.join('')
              $rootScope.$broadcast("ChangeOn#{type}", change.id)
              _this.changes(last)

        ,(err) -> #Error
          _this.changes(last)
      )
  }
)
