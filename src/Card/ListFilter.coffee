angular.module('card').
filter('list', () ->
  return (cards, list_id) ->
    results = []

    for card in cards
      if card.list_id == list_id
        results.push(card)

    return results
)
