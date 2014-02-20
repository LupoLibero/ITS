ng.factory('notification', ()->
  return {
    alerts: []

    addAlert: (message, type) ->
      add=
        message:  message
        type:     type

      if this.alerts.length == 2
        this.alerts.splice(1,1)
      for alert, i in this.alerts
        if alert.message == add.message
          this.alerts.splice(i,1)
          break

      this.alerts.unshift(add)

    closeAlert: (index) ->
      this.alerts.splice(index, 1)
  }
)
