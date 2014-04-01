angular.module('card').
factory('cardUtils', ->
  return {
    makeObject: (cards) ->
      results = {
        lists: ["ideas", "todo", "estimated", "funded", "done"]
        cards: []
        rank:  {}
        cost_estimate: {}
        payment: {}
        votes: {}
        langs: {}
      }

      for card in cards
        if card.type == 'vote'
          if results.rank.hasOwnProperty(card.card_id)
            results.rank[card.card_id] += 1
          else
            results.rank[card.card_id] = 1

        if card.type == 'card'
          card.num = card.id.split('.')[1]
          for lang of card.avail_langs
            if results.langs.hasOwnProperty(lang)
              results.langs[lang] += 1
            else
              results.langs[lang] = 1

        if card.type == 'cost_estimate'
          results[card.type][card.card_id] = card.estimate

        else if card.type == 'payment'
          results[card.type][card.card_id] = card.amount

        else if card.type == 'vote'
          if not results.votes.hasOwnProperty(card.card_id)
            results.votes[card.card_id] = {}
          results.votes[card.card_id][card.voter] = card.vote

        else if card.type == 'card'
          results["#{card.type}s"].push(card)

      return results

    toObject: (cards) ->
      results = {}
      for card in cards
        results[card.id] = card
      return results
  }
)
