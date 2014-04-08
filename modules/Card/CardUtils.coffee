angular.module('card').
factory('cardUtils', ->
  return {
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
