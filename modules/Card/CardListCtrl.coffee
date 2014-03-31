angular.module('card').
controller('CardListCtrl', ($scope, $route, cards_default, cards, config, $modal, login, Card, longPolling, url) ->
  $scope.login      = login
  $scope.project    = $route.current.locals.project

  makeObject = (cards) ->
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

  toObject = (cards) ->
    results = {}
    for card in cards
      results[card.id] = card
    return results

  $scope.default     = makeObject(cards_default)
  $scope.translation = toObject(cards)


  $scope.orderByRank = () ->
    (doc) ->
      -1*$scope.default.rank[doc.id]


  # Translate
  $scope.currentLang = window.navigator.language
  $scope.langs       = $scope.default.langs
  $scope.allLangs    = config[1].value
  $scope.nbCard      = $scope.default.cards.length

  $scope.titleSave = (id, text) ->
    return $scope.save(id, 'title', text)

  $scope.save = (id, field, text) ->
    Card.update({
      update: 'update_field'

      id:      id
      _rev:    $scope.translation[id]._rev
      element: field
      value:   text
      lang:    $scope.currentLang
    }).then(
      (data) -> #Success
        console.log "success"
    )

  $scope.$on('LangBarChangeLanguage', ($event, lang) ->
    Card.all({
      startkey: [$scope.project.id, lang]
      endkey:   [$scope.project.id, lang, {}]
      reduce: false
    }).then(
      (data) -> #Success
        $scope.translation = toObject(data)
        $scope.$emit('LanguageChangeSuccess')
    )
  )


  $scope.$on('addCard', ($event, card)->
    $scope.default.cards.push(card)
    $scope.nbCard = $scope.default.cards.length
  )


  longPolling.start('cards')

  $scope.$on('ChangesOnCards', ($event, _id)->
    type      = _id.split(':')[0]
    id        = _id.split(':')[-1..-1][0].split('-')[0]
    projectId = id.split('.')[0]

    card = null
    for piece in $scope.default.cards
      if piece.id == id
        card = piece
        break

    if card?
      lang = (if type != 'card' then 'default' else card.lang)
    else
      lang = 'default'

    Card.get({
      view:        'all'
      key:         [projectId, lang, id]
      group_level: 3
    }).then(
      (data) -> #Success
        # if lang == 'default'
        #   $scope.results = recursive_merge($scope.results, data, {
        #     cards: mergeArrayById
        #     votes: mergeVotes
        #   }, true, true)
        # else
        #   $scope.default.cards = mergeArrayById('cards', $scope.results, data)
    )
  )


  $scope.$watch($route.current.params.card_num, (card_num) ->
    if card_num != undefined
      modal = $modal.open({
        templateUrl: 'partials/card/show.html'
        controller:  'CardCtrl'
        keyboard:    false
        resolve:
          parent: ($q) ->
            defer      = $q.defer()
            card_num   = $route.current.params.card_num
            project_id = $route.current.params.project_id
            found      = false
            for card in $scope.default.cards
              if card.id == "#{project_id}.#{card_num}"
                defer.resolve(card)
                found = true
            if not found then defer.reject()
            return defer.promise
          card_default: (Card, $route) ->
            card_num   = $route.current.params.card_num
            project_id = $route.current.params.project_id
            return Card.view({
              view: 'get'
              startkey: ["#{project_id}.#{card_num}", 'default']
              endkey:   ["#{project_id}.#{card_num}", 'default', {}]
            })
          card: (Card, $route) ->
            card_num   = $route.current.params.card_num
            project_id = $route.current.params.project_id
            return Card.view({
              view: 'get'
              startkey: ["#{project_id}.#{card_num}", window.navigator.language]
              endkey:   ["#{project_id}.#{card_num}", window.navigator.language, {}]
            })
          comments: (Comment, $route) ->
            card_num   = $route.current.params.card_num
            project_id = $route.current.params.project_id
            return Comment.all({
              startkey: ["card:#{project_id}.#{card_num}", 0]
              endkey:   ["card:#{project_id}.#{card_num}", {}]
            })
      })

      modal.result.then( (->), ->
        url.redirect('card.list', {
          project_id: $route.current.locals.project.id
        })
      )
  )

)
