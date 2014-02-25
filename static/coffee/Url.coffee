ng.factory('url', ($location) ->
  return {
    sufix: ->
      if $location.$$html5
        return ''
      else
        return '#'
      return sufix

    blog: () ->
      url = "/blog"
      return this.sufix() + url

    projectList: () ->
      url = "/project"
      return this.sufix() + url

    project: (project_id) ->
      url = "/project/#{project_id}"
      return this.sufix() + url

    demandList: (project_id) ->
      url = "/project/#{project_id}/demand"
      return this.sufix() + url

    demand: (project_id, demand_id) ->
      demand_id = demand_id.split('#')[1]
      url = "/project/#{project_id}/demand/#{demand_id}"
      return this.sufix() + url

  }
)
