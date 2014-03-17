angular.module('demand').
controller('DemandListCtrl', ($scope, demands_default, demands, project, $modal, login, config, Demand) ->
  $scope.login      = login
  $scope.project    = project
  $scope.demandList = angular.extend(demands_default, demands)

  $scope.hasVote = (demand) ->
    return demand.votes.hasOwnProperty(login.actualUser.name)

  $scope.$on('SessionChanged', ->
    if login.isNotConnect()
      $scope.messageTooltip = "You need to be connected"
    else if login.hasRole('sponsor')
      $scope.messageTooltip = "Vote for this demand"
    else
      $scope.messageTooltip = "You need to be a sponsor"

    for demand in $scope.demandList
      demand.check =  $scope.hasVote(demand)
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

  $scope.newDemandPopup = ->
    if login.isNotConnect() # If the user is not connect
      $scope.notif.addAlert('You need to be connected for doing that!', 'danger')
      return false

    modalNewDemand = $modal.open({
      templateUrl: '../partials/demand/new.html'
      controller:  'NewDemandCtrl'
    })

    modalNewDemand.result.then( (data) ->
      data.check = true
      $scope.demandList.push(data)
      $scope.notif.addAlert('You demand is create!', 'success')
    )

  $scope.getCategory = (key) ->
    categories = config[0].value
    if categories.hasOwnProperty(key)
      return categories[key]
    else
      return key

  $scope.getStatus = (key) ->
    statuses = config[1].value
    if statuses.hasOwnProperty(key)
      return statuses[key]
    else
      return key
)
