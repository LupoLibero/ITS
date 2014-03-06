ng.filter('capitalize', () ->
  return (value) ->
    if value? and typeof value == 'string'
      value = value.toLowerCase()
      return value.substring(0,1).toUpperCase() + value.substring(1)
    else
      return value
)
