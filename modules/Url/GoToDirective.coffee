angular.module('url').
directive('goto', (url) ->
  return {
    restrict: 'A'
    link: (scope, element, attrs) ->
      route = url.getRouteByName(attrs.goto)
      params = {}

      for param in url.getRouteParams(route)
        realName = url.getParamName(param)

        # need to transfor test_id in testId
        name = realName.split('_')
        for piece, i in name
          if i != 0
            name[i] = piece.substring(0,1).toUpperCase() + piece.substring(1)
        name = name.join('')

        if attrs[name] != undefined
          params[realName] = attrs[name]

      element.attr('href', url.get(attrs.goto, params) )
  }
)
