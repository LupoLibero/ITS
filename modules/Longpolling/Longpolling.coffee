angular.module('card').
factory('longPolling', (db, $http, $rootScope, $q) ->
  return {
    filter: ''
    event: {}

    start: (filter, params) ->
      @stop(filter)

      window.EventSource = false

      if not window.EventSource
        @changes(filter, params)
      else
        @eventsource(filter, params)

    stop: (filter) ->
      if not window.EventSource
        $rootScope.$broadcast('CloseLongpolling', filter)
      else if @event.hasOwnProperty(filter)
        @event[filter].close()

    send: (filter, _id) ->
      filter = filter[0].toUpperCase() + filter[1..-1].toLowerCase()
      $rootScope.$broadcast("ChangesOn#{filter}", _id)

    changes: (filter, params = {}, last = "now") ->
      _this = this
      url   = "#{db.url}/_changes?feed=longpoll&heartbeat=10000&filter=#{db.name}/#{filter}&since=#{last}"
      url   = @inject(url, params)

      $http.get(url, {
        timeout: () ->
          defer = $q.defer()
          $rootScope.$on('$routeChangeSuccess', ->
            defer.resolve("end")
          )
          $rootScope.$on('CloseLongpolling', ($event, name) ->
            if name == filter
              defer.resolve("end")
          )
          return defer.promise

      }).then(
        (data) -> #Success
          if data.data.hasOwnProperty('last_seq')
            last = data.data.last_seq

          if typeof data.data.results == 'object'
            for change in data.data.results
              @send(filter, change.id)
              _this.changes(filter, params, last)
          else
            _this.changes(filter, params, last)

        ,(err) -> #Error
          _this.changes(filter, params, last)
      )

  eventsource: (filter, params = {}) ->
      url   = "#{db.url}/_changes?filter=#{db.name}/#{filter}&feed=eventsource&since=now"
      url   = @inject(url, params)
      @event[filter] = new EventSource(url)

      onmessage = (e) ->
        change = JSON.parse(e.data)
        @send(filter, change.id)

      @event[filter].addEventListener('message', onmessage, false)

    inject: (url, params = {}) ->
      for key, value of params
        url += "&#{key}=#{value}"

      return url
  }
)
