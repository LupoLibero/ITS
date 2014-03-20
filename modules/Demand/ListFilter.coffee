angular.module('demand').
filter('list', () ->
  return (demands, list_ids, list_id) ->
    results = []
    for key, demand of demands
      if list_ids[demand.id] == list_id
        results.push(demand)

    return results
)
