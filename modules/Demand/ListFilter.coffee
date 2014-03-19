angular.module('demand').
filter('list', () ->
  return (demands, list_id) ->
    results = []
    for key, demand of demands
      if demand.list_id == list_id
        results.push(demand)

    return results
)
