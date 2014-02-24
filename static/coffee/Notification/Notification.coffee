ng.factory('notification', ($timeout) ->
  return {
    alerts: []
    displayTime: 5000

    addAlert: (message, type) ->
      add=
        message:  message
        type:     type
        time:     new Date().getTime()

      # If there are two alert delete the last one
      if this.alerts.length == 2
        this.alerts.pop()

      # If the alert is already display delete it
      for alert, i in this.alerts
        if alert.message == add.message
          this.alerts.splice(i,1)
          break

      # at to the begining the alert
      this.alerts.unshift(add)

      # Delete automaticaly the alert
      this.autoDelete()

    autoDelete: ->
      _this = this
      $timeout( ->
        for alert, i in _this.alerts
          timespend = new Date().getTime() - alert.time
          if timespend >= _this.displayTime
            _this.alerts.splice(i,1)
      , _this.displayTime)

    closeAlert: (index) ->
      this.alerts.splice(index, 1)
  }
)
