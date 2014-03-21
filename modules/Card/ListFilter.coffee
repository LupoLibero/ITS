angular.module('card').
filter('list', () ->
  return (cards, list_ids, list_id) ->
    results = []
    for key, card of cards
      if list_ids[card.id] == list_id
        results.push(card)

    return results
)
