ng.factory('notification', ()->
  return {
    alerts: []

    addAlert: (message, type) ->
      add=
        message:  message
        type:     type

      found = false
      for alert in this.alerts
        if alert.message == add.message
          found = true
          break

      if not found
        this.alerts.push(add)

    closeAlert: (index) ->
      this.alerts.splice(index, 1)
  }
)
