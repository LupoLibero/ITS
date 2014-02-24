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

    demand: (project_id, demand_id) ->
      demand_id = demand_id.split('#')[1]
      url = "/project/" + project_id + "/demand/" + demand_id
      return this.sufix() + url

  }
)
