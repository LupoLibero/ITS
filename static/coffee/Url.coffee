ng.factory('url', ($location) ->
  return {
    prefix: ->
      if $location.$$html5
        return ''
      else
        return '#'

    blog: () ->
      url = "/blog"
      return this.prefix() + url

    projectList: () ->
      url = "/project"
      return this.prefix() + url

    project: (project_id) ->
      url = "/project/#{project_id}"
      return this.prefix() + url

    demandList: (project_id) ->
      url = "/project/#{project_id}/demand"
      return this.prefix() + url

    demand: (project_id, demand_id) ->
      demand_id = demand_id.split('#')[1]
      url = "/project/#{project_id}/demand/#{demand_id}"
      return this.prefix() + url

  }
)
