angular.module('demand').
controller('DemandListCtrl', ($scope, demands_default, demands, project, $modal, login, config, Demand) ->

  # Add demands and project to the scope
  $scope.project    = project
  $scope.demandList = demands_default

  # Replace the default demand by the translate demand
  for demand, i in demands_default
    for trad in demands
      if trad.id == demand.id
        demands_default[i] = trad

  # If the user has already vote for this demand
  $scope.hasVote = (demand) ->
    return demand.votes.hasOwnProperty(login.actualUser.name)

  # Event for checking all the votes into the scope
  $scope.$on('CheckVote', ->
    for demand in $scope.demandList
      demand.check =  $scope.hasVote(demand)
  )

  # Check at the begining
  $scope.$emit('CheckVote')

  # If the user connect
  $scope.$on('SignIn', ->
    $scope.$emit('CheckVote')
  )

  # If the user disconnect
  $scope.$on('SignOut', ->
    $scope.$emit('CheckVote')
  )

  # Function call when a user vote
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

  # Create a new demand
  $scope.newDemandPopup = ->
    if login.isNotConnect() # If the user is not connect
      $scope.notif.addAlert('You need to be connected for doing that!', 'danger')
      return false

    # Create the popup
    modalNewDemand = $modal.open({
      templateUrl: '../partials/demand/new.html'
      controller:  'NewDemandCtrl'
    })

    # When the popup is close
    modalNewDemand.result.then( (data) ->
      data.check = true
      $scope.demandList.push(data)
      $scope.notif.addAlert('You demand is create!', 'success')
    )

  # Get the real value
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
