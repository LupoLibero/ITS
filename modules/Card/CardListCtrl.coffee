angular.module('card').
controller('CardListCtrl', ($scope, $route, cards_default, cards, $modal, login, Card, longPolling, url) ->
  $scope.login      = login
  $scope.project    = $route.current.locals.project

  recursive_merge = (dst, src, special_merge, overwrite, emptyIfSrcEmpty) ->
    if !dst
      return src
    if !src
      if emptyIfSrcEmpty
        return src
      return dst
    if typeof(src) == 'object' and typeof src == 'object'
      for e of src
        if e of special_merge
          dst[e] = special_merge[e](e, dst, src)
        else
          dst[e] = recursive_merge(dst[e], src[e], special_merge, overwrite, emptyIfSrcEmpty)
    else
      if overwrite
        dst = src
    return dst

  mergeArrayById = (element, dstParent, srcParent) ->
    newDst = []
    dst    = dstParent[element]
    src    = srcParent[element]
    alreadyPushed   = {}
    for demandDst in dst
      for demandSrc in src
        if demandDst.id == demandSrc.id
          newDst.push demandSrc
          alreadyPushed[demandDst.id] = true
          continue
      if not alreadyPushed[demandDst.id]
        newDst.push demandDst
        alreadyPushed[demandDst.id] = true
    for demandSrc in src
      if not alreadyPushed[demandSrc.id]
        newDst.push demandSrc
    return newDst

  mergeVotes = (element, dstParent, srcParent) ->
    newDst = {}
    dst    = dstParent[element]
    src    = srcParent[element]
    for demandId, dstVotes of dst
      if demandId of src
        newDst[demandId] = {}
        for voter, vote of dstVotes
          if voter not in src[demandId]
            continue
          newDst[demandId][voter] = vote
        for voter, vote of src[demandId]
          newDst[demandId][voter] = vote
      else
        newDst[demandId] = dstVotes
    return newDst

  $scope.results = cards_default[0]
  $scope.results.cards = mergeArrayById('cards', $scope.results, cards[0])

  longPolling.start('cards')

  $scope.orderByRank = () ->
    (doc) ->
      -1*$scope.results.rank[doc.id]

  $scope.$on('addCard', ($event, card)->
    $scope.results.cards.push(card)
    $scope.results.list_id[card.id] = 'ideas'
  )

  $scope.$on('ChangesOnCards', ($event, _id)->
    type      = _id.split(':')[0]
    id        = _id.split(':')[-1..-1][0].split('-')[0]
    projectId = id.split('.')[0]

    card = null
    for piece in $scope.results.cards
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
        if lang == 'default'
          $scope.results = recursive_merge($scope.results, data, {
            cards: mergeArrayById
            votes: mergeVotes
          }, true, true)
        else
          $scope.results.cards = mergeArrayById('cards', $scope.results, data)
    )
  )

  $scope.$watch($route.current.params.card_num, (card_num) ->
    if card_num != undefined
      modal = $modal.open({
        templateUrl: 'partials/card/show.html'
        controller:  'CardCtrl'
        resolve:
          parent: ($q) ->
            defer = $q.defer()
            card_num   = $route.current.params.card_num
            project_id = $route.current.params.project_id
            found = false
            for card in $scope.results.cards
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
