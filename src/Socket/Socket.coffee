angular.module('socket').
factory('socket', ($location, $q, $timeout, $rootScope) ->
  host = $location.host()
  return {
    socket: io.connect("//#{host}:8000")

    emit: (event, data)->
      defer = $q.defer()
      @socket.emit(event, data, (message)->
        message = message.split(':')

        if message[0] == "Done"
          defer.resolve(message[1..-1].join(':'))
        else if message[0] == "Error"
          err = message[1..-1].join(':')
          err = JSON.parse(err)
          $rootScope.$broadcast('DatabaseError', err)
          defer.reject(err)
      )

      $timeout( ->
        defer.reject('timeout')
      ,3000)
      return defer.promise

    on: (event, callback)->
      @socket.on(event, callback)
  }
)
