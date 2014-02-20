ng.filter('default', () ->
  return (value, param) ->
    if value is undefined or value? or value is ''
      return param
    else
      return value
)
