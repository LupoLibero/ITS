ng.factory('url', ($location, $route) ->
  return {
    prefix: ->
      if $location.$$html5
        return ''
      else
        return '#'

    get: (name, params = {}) ->
      route = this.getRouteByName(name)
      return this.prefix() + this.inject(params, route)

    getRouteByName: (name) ->
      for key, route of $route.routes
        if route.hasOwnProperty('name') and route.name == name
          return route.originalPath
      return ''

    inject: (params, route) ->
      url = route
      for param in this.getRouteParams(route)
        name = this.getParamName(param)
        if not params.hasOwnProperty(name) && !this.isOptional(param)
          throw "Impossible to generate the url because one/some params are missing"
          return ''

        if params[name] != undefined
          url = url.replace(param, params[name])
        else
          url = url.replace(param, '')

      if url[url.length-1] == "/"
        url = url.substr(0, url.length-1)
      return url

    getRouteParams: (route) ->
      return route.match(/\:[\w-?]*/g)

    getParamName: (param) ->
      if this.isOptional(param)
        return param.substr(1, param.length-2)
      else
        return param.substr(1)

    isOptional: (param) ->
      return param[param.length-1] == '?'

  }
)
