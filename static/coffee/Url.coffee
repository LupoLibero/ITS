ng.factory('url', ($location) ->
  return {
    html5: ->
      return $location.$$html5

    sufix: ->
      if this.html5()
        return ''
      else
        return '#'
      return sufix

    ticket: (project_id, ticket_id) ->
      ticket_id = ticket_id.split('#')[1]
      url = "/project/" + project_id + "/ticket/" + ticket_id
      return this.sufix() + url

  }
)
