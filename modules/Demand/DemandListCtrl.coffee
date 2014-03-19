angular.module('demand').
controller('DemandListCtrl', ($scope, demands_default, demands, project, $modal, login, config, Demand, $http, $q, $rootScope) ->
  $scope.login      = login
  $scope.project    = project

  recursive_merge = (dst, src, special_merge) ->
    if !dst
      return src
    if !src
      return dst
    if typeof(src) == 'object'
      console.log src, dst
      for e in src
        if(e in special_merge)
          dst[e] = special_merge[e](e, dst, src);
        else
          dst[e] = recursive_merge(dst[e], src[e], special_merge)
    dst = src;
    return dst;
  $scope.results = recursive_merge(demands, demands_default, {})[0];

  $scope.hasVote = (demand) ->
    return demand.votes.hasOwnProperty(login.actualUser.name)

  changes = (last = "now") ->
    url = "lupolibero/_changes?feed=longpoll&filter=its/demands&since=#{last}"
    $http.get(url, {
      timeout: () ->
        defer = $q.defer()
        $rootScope.$on('$routeChangeSuccess', ($event, current)->
          defer.resolve("end")
        )
        return defer.promise
    }).then(
      (data) -> #Success
        last = data.data.last_seq

        if typeof data.data.results == 'object'
          for change in data.data.results
            split = change.id.split('-')
            type  = split[0]
            id    = split[1]
            if type == 'demand' and $scope.results.demands.hasOwnProperty(id)
              p_id  = id.split('#')[0].toLowerCase()
              Demand.get({
                view:        'all'
                key:         [p_id, 'en', id]
                group_level: 3
              }).then(
                (data) -> #Success
                  angular.extend($scope.results.demands[id], data.demands[id])
                  changes(last)
              )
      ,(err) -> #Error
        changes(last)
    )
  changes()

  $scope.$on('SessionChanged', ->
    if login.isNotConnect()
      $scope.messageTooltip = "You need to be connected"
    else if login.hasRole('sponsor')
      $scope.messageTooltip = "Vote for this demand"
    else
      $scope.messageTooltip = "You need to be a sponsor"
  )

  $scope.vote = ($index) ->
    demand = $scope.demandList[$index] # Get the demand
    if not $scope.hasVote(demand)
      action = 'vote'
    else
      action = 'cancel_vote'
    Demand.update({
      id: demand.id
      update: action
    }).then(
      (data) -> #Success
        if action == 'vote'
          demand.check = true
          demand.rank  = demand.rank+1
          demand.votes[login.actualUser.name] = true
        else
          demand.check = false
          demand.rank  = demand.rank-1
          delete demand.votes[login.actualUser.name]
      ,(err) -> #Error
        demand.check = !demand.check # Cancel the interface
    )
)
