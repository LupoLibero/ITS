angular.module('card').
factory('longPolling', (db, $http, $rootScope, $q) ->
  return {
    filter: ''
    setFilter: (filter) ->
      this.filter = filter

    start: ->
      if not window.EventSource
        @changes()
      else
        @eventsource()

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

          if typeof data.data.results == 'object'
            for change in data.data.results
              $rootScope.$broadcast("Changes", change.id)
              _this.changes(last)
          else
            _this.changes(last)

        ,(err) -> #Error
          _this.changes(last)
      )

    eventsource: ->
      _this = this

      event = EventSource("#{db.url}/_changes?filter=#{@filter}&feed=eventsource&since=now")

      event.onerror = (e) ->
        console.log e

      event.onmessage = (e) ->
        change = JSON.parse(e.data)
        $rootScope.$broadcast("Changes", change.id)
  }
)
