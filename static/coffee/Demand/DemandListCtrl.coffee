ng.controller('DemandListCtrl', ($scope, demands, project, $modal, login, config, $http, name, dbUrl) ->

  # Add demands and project to the scope
  $scope.project    = project
  $scope.demandList = demands

  # If the user has already vote for this demand
  $scope.hasVote = (demand) ->
    return demand.votes.hasOwnProperty(login.actualUser.name)

  # Event for checking all the votes into the scope
  $scope.$on('CheckVote', ->
    for demand in $scope.demandList
      demand.check =  $scope.hasVote(demand)
  )

  # Function call when a user vote
  $scope.vote = ($index) ->
    demand = $scope.demandList[$index] # Get the demand

    if login.isNotConnect()
      $scope.notif.addAlert('You need to be connected for doing that!', 'danger')
      return true

    url = dbUrl + "/_design/#{name}/_update"
    id = demand.id.replace('#', '%23')

    if not $scope.hasVote(demand)
      action = 'vote'
    else
      action = 'cancel_vote'

    $http.put("#{url}/#{action}/demand-#{id}").then(
      (data) -> #Success
        if action == 'vote'
          demand.check = true
          demand.rank  = demand.rank+1
          demand.votes[login.actualUser.name] = true
        else
          demand.check = true
          demand.rank  = demand.rank-1
          delete demand.votes[login.actualUser.name]
      ,(err) -> #Error
        $scope.notif.addAlert('An Error is send! Please try again.', 'danger')
        demand.check = !demand.check # Cancel the interface
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

  # Create a new demand
  $scope.newDemandPopup = ->
    if login.isNotConnect() # If the user is not connect
      $scope.notif.addAlert('You need to be connected for doing that!', 'danger')
      return false

    # Create the popup
    modalNewDemand = $modal.open({
      templateUrl: '../partials/demand/new.html'
      controller:  'NewDemandCtrl'
      resolve: {
        categories: ($q) ->
          defer = $q.defer()
          defer.resolve(config[0].value)
          return defer.promise
        project: ($q) ->
          defer = $q.defer()
          defer.resolve(project)
          return defer.promise
      }
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
    statuses = config[2].value
    if statuses.hasOwnProperty(key)
      return statuses[key]
    else
      return key

  $scope.getResolution = (key) ->
    resolutions = config[1].value
    if resolutions.hasOwnProperty(key)
      return statuses[key]
    else
      return key
)
