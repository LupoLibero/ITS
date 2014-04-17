angular.module('socket').
factory('socket', ($location, $q, $timeout) ->
  host = $location.host()
  return {
    socket: io.connect("//#{host}:8800")

    emit: (event, data)->
      defer = $q.defer()
      @socket.emit(event, data, (message)->
        console.log message
        message = message.split(':')

        if message[0] == "#{event} done"
          defer.resolve(message[1..-1].join())
        else if message[0] == "#{event} error"
          defer.reject(message[1..-1].join())
      )

      $timeout( ->
        defer.reject('timeout')
      ,1000)
      return defer.promise

    on: (event, callback)->
      @socket.on(event, callback)
  }
)
