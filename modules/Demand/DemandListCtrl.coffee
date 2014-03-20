angular.module('demand').
controller('DemandListCtrl', ($scope, demands_default, demands, project, $modal, login, config, Demand, longPolling) ->
  $scope.login      = login
  $scope.project    = project

  recursive_merge = (dst, src, special_merge) ->
    #typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'
    #console.log dst, src
    if !dst
      return src
    if !src
      return dst
    if typeof(src) == 'object'
      for e of src
        #console.log 'e', e
        if e of special_merge
          dst[e] = special_merge[e](e, dst, src)
        else
          dst[e] = recursive_merge(dst[e], src[e], special_merge)
    else
      #console.log "!!!overwritting!!!", dst, src
      dst = src
    return dst
  demandArraysMerge = (element, dstParent, srcParent) ->
    console.log 'special', element, dstParent, srcParent
    newDst = []
    dst    = dstParent[element]
    src    = srcParent[element]
    alreadyPushed   = {}
    for demandDst in dst
      console.log 'dst', demandDst.id
      for demandSrc in src
        console.log 'src', demandSrc.id
        if demandDst.id == demandSrc.id
          newDst.push demandSrc
          alreadyPushed[demandDst.id] = true
          console.log 'push'
          continue
      if not alreadyPushed[demandDst.id]
        console.log 'notAvailInSrc, push'
        newDst.push demandDst
        alreadyPushed[demandDst.id] = true
    for demandSrc in src
      console.log 'src', demandSrc.id
      if not alreadyPushed[demandSrc.id]
        console.log 'push2'
        newDst.push demandSrc
    return newDst

  $scope.results = recursive_merge(demands_default, demands, {demands: demandArraysMerge})[0]
  console.log $scope.results

  longPolling.setFilter('its/demands')
  longPolling.start()

  $scope.orderByRank = () ->
    (doc) ->
      -1*$scope.results.rank[doc.id]

  $scope.$on('ChangeOnDemand', ($event, _id)->
    id    = _id.split('-')[1]
    p_id  = id.split('#')[0].toLowerCase()

    Demand.get({
      view:        'all'
      key:         [p_id, $scope.results.demands[id].lang, id]
      group_level: 3
    }).then(
      (data) -> #Success
        angular.extend($scope.results.demands[id], data.demands[id])
    )
  )

  $scope.hasVote = (demand) ->
    id   = demand.id
    vote = $scope.results.vote

    #console.log vote

    return vote.hasOwnProperty(id) and vote[id].hasOwnProperty(login.getName())
)
