angular.module('demand').
controller('DemandListCtrl', ($scope, demands_default, demands, project, $modal, login, config, Demand, longPolling) ->
  $scope.login      = login
  $scope.project    = project

  recursive_merge = (dst, src, special_merge, overwrite, emptyIfSrcEmpty) ->
    if !dst
      return src
    if !src
      #console.log 'src empty', dst, src, emptyIfSrcEmpty
      if emptyIfSrcEmpty
        #console.log 'so empty dst'
        return src
      return dst
    if typeof(src) == 'object' and typeof src == 'object'
      for e of src
        if e == "votes"
          #console.log e, dst, src
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
    #console.log "mergeVotes", dst, src
    for demandId, dstVotes of dst
      #console.log demandId, dstVotes
      if demandId of src
        newDst[demandId] = {}
        for voter, vote of dstVotes
          #console.log "dst", voter, vote
          if voter not in src[demandId]
            continue
          newDst[demandId][voter] = vote
        for voter, vote of src[demandId]
          #console.log "src", voter, vote
          newDst[demandId][voter] = vote
      else
        newDst[demandId] = dstVotes
    return newDst
  $scope.results = recursive_merge(demands_default, demands, {demands: mergeArrayById}, true, false)[0]

  longPolling.setFilter('its/demands')
  longPolling.start()

  $scope.orderByRank = () ->
    (doc) ->
      -1*$scope.results.rank[doc.id]

  $scope.$on('Changes', ($event, _id)->
    type  = _id.split('-')[0]
    if type != 'demand'
      _id = _id.split('--')[1]
    id   = _id.split('-')[1]
    p_id = id.split('-')[0]

    demand = null
    for piece in $scope.results.demands
      if piece.id == id
        demand = piece
        break

    if demand?
      Demand.get({
        view:        'all'
        key:         [p_id, (if type != 'demand' then 'default' else demand.lang), id]
        group_level: 3
      }).then(
        (data) -> #Success
          console.log "data", data
          $scope.results = recursive_merge($scope.results, data, {
            demands: mergeArrayById
            votes: mergeVotes
          }, true, true)
      )
  )

  $scope.addingComment = ->
    $scope.adding = true

  $scope.addDemand = ($event) ->
    if $event.key == 'Enter'
      $event.preventDefault()

      Demand.view({
        view: 'ids'
        key:  project.id
      }).then(
        (data) -> #Success
          # If it's the first demand of the project
          if data.length == 0
            count = 1
          else
            count = data[0].max + 1

          id = project.id+'-'+count
          # Create Demand
          Demand.update({
            update: 'create'

            id:          id
            project_id:  project.id
            title:       $scope.newDemand
            lang:        window.navigator.language
          }).then(
            (data) -> #Success
              $scope.newDemand = ''
              $scope.adding    = false
              console.log data
          )
      )
)
