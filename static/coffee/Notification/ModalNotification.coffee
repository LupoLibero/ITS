ng.factory('modalNotification', () ->
  return {
    alert: {}

    setAlert: (msg, type)->
      this.alert= {
          message:  msg
          type:     type
          show:     true
      }

    closeAlert: ->
      this.alert.show = false

    displayAlert: ->
      return this.alert.show
  }
)
