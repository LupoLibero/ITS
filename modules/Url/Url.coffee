ng.factory('url', ($location, $route) ->
  return {
    prefix: ->
      if $location.$$html5
        return ''
      else
        return '#'

    redirect: (name, params = {}) ->
      route = this.getRouteByName(name)
      route = this.inject(params, route)
      route = route.replace('%23', '#')
      $location.path(route)

    get: (name, params = {}) ->
      route = this.getRouteByName(name)
      return this.prefix() + this.inject(params, route)

    getRouteByName: (name) ->
      for key, route of $route.routes
        if route.hasOwnProperty('name') and route.name == name
          return route.originalPath
      return ''

    inject: (params, route) ->
      if route == ""
        return ""

      url = route
      for param in this.getRouteParams(route)
        name = this.getParamName(param)
        if not params.hasOwnProperty(name) && !this.isOptional(param)
          throw "Impossible to generate the url because one/some params are missing:  #{name}"
          return ''

        if params[name] != undefined
          url = url.replace(param, params[name].replace('#', '%23'))
        else
          url = url.replace(param, '')

      if url[url.length-1] == "/"
        url = url.substr(0, url.length-1)
      return url

    getRouteParams: (route) ->
      result = route.match(/\:[\w-?]*/g)
      if result == null
        result = []
      return result

    getParamName: (param) ->
      if this.isOptional(param)
        return param.substr(1, param.length-2)
      else
        return param.substr(1)

    isOptional: (param) ->
      return param[param.length-1] == '?'

  }
)
