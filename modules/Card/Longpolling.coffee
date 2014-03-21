angular.module('card').
factory('longPolling', (db, $http, $rootScope, $q) ->
  return {
    filter: ''
    setFilter: (filter) ->
      this.filter = filter

    start: ->
      @changes()

    changes: (last = "now") ->
      _this = this
      url   = "#{db.url}/_changes?feed=longpoll&heartbeat=10000&filter=#{@filter}&since=#{last}"

      $http.get(url, {
        timeout: () ->
          defer = $q.defer()
          $rootScope.$on('$routeChangeSuccess', ->
            defer.resolve("end")
          )
          return defer.promise

      }).then(
        (data) -> #Success
          if data.data.hasOwnProperty('last_seq')
            last = data.data.last_seq
          console.log "changeObject", typeof data.data.results, data.data.results
          if typeof data.data.results == 'object'
            for change in data.data.results
              $rootScope.$broadcast("Changes", change.id)
              _this.changes(last)
          else
            _this.changes(last)

        ,(err) -> #Error
          console.log 'changeError', err
          _this.changes(last)
      )
  }
)
