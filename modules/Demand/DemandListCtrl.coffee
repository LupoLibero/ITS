angular.module('demand').
controller('DemandListCtrl', ($scope, demands_default, demands, project, $modal, login, config, Demand, longPolling) ->
  $scope.login      = login
  $scope.project    = project

  recursive_merge = (dst, src, special_merge) ->
    if !dst
      return src
    if !src
      return dst
    if typeof(src) == 'object'
      for e in src
        if(e in special_merge)
          dst[e] = special_merge[e](e, dst, src)
        else
          dst[e] = recursive_merge(dst[e], src[e], special_merge)
    dst = src
    return dst
  $scope.results = recursive_merge(demands, demands_default, {})[0]

  longPolling.setFilter('its/demands')
  longPolling.start()

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

    console.log vote

    return vote.hasOwnProperty(id) and vote[id].hasOwnProperty(login.getName())
)
