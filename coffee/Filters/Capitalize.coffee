ng.filter('capitalize', () ->
  return (value) ->
    if value? and typeof value == 'string'
      results = []
      for piece in value.split(' ')
        piece = piece.substring(0,1).toUpperCase() + piece.substring(1).toLowerCase()
        results.push(piece)

      return results.join(' ')
    else
      return value
)
