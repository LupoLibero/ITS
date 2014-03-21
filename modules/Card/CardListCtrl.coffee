angular.module('card').
controller('CardListCtrl', ($scope, $route, cards_default, cards, project, $modal, login, config, Card, longPolling) ->
  $scope.login      = login
  $scope.project    = project

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
  $scope.results = recursive_merge(cards_default, cards, {cards: mergeArrayById}, true, false)[0]

  longPolling.setFilter('its/cards')
  longPolling.start()

  $scope.orderByRank = () ->
    (doc) ->
      -1*$scope.results.rank[doc.id]

  $scope.$on('Changes', ($event, _id)->
    console.log _id
    type  = _id.split('-')[0]
    if type != 'card'
      _id = _id.split('--')[1]
    id   = _id.split('-')[1]
    p_id = id.split('-')[0]

    card = null
    for piece in $scope.results.cards
      if piece.id == id
        card = piece
        break

    if card?
      Demand.get({
        view:        'all'
        key:         [p_id, (if type != 'card' then 'default' else card.lang), id]
        group_level: 3
      }).then(
        (data) -> #Success
          $scope.results = recursive_merge($scope.results, data, {
            cards: mergeArrayById
            votes: mergeVotes
          }, true, true)
      )
  )

  if $route.current.params.card_num != undefined
    $modal.open({
      templateUrl: 'partials/card/show.html'
      controller:  'CardCtrl'
      resolve:
        card_default: ->
          return $route.current.locals.card_default
        card: ->
          return $route.current.locals.card
    })
)
