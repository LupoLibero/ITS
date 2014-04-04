angular.module('card').
factory('cardUtils', ->
  return {
    makeCards: (def, trans) ->
      cards = angular.copy(def)
      for card, i in cards
        for t in trans
          if card.id == t.id
            cards[i] = t
            break

        for key, value of card.title
          cards[i].lang  = key
          cards[i].title = value

        cards[i].num = card.id.split('.')[1]

      return cards

    getLangs: (cards) ->
      langs = {}
      for card in cards
        for lang in card.avail_langs
          if langs[lang]?
            langs[lang] += 1
          else
            langs[lang] = 1

      return langs
  }
)
