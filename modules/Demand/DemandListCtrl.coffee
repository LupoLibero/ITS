angular.module('demand').
controller('DemandListCtrl', ($scope, demands_default, demands, project, $modal, login, config, Demand) ->
  $scope.login      = login
  $scope.project    = project

  $scope.results = angular.extend(demands_default, demands)[0]

  $scope.hasVote = (demand) ->
    return demand.votes.hasOwnProperty(login.actualUser.name)

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
