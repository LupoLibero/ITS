ng.controller('DemandListCtrl', ($scope, demands, project, $modal, login, notification, config, $http, name, dbUrl) ->
  $scope.project    = project

  # Add demands to the scope
  $scope.demandList = demands

  # Vote System
  $scope.hasVote = (demand) ->
    if demand.votes.hasOwnProperty(login.actualUser.name)
      return true
    else
      return false

  $scope.$on('CheckVote', ->
    for demand in $scope.demandList
      if $scope.hasVote(demand)
        demand.check = true
      else
        demand.check = false
  )

  $scope.vote = ($index) ->
    if not login.isConnect()
      notification.addAlert('You need to be connected for doing that!', 'danger')

    url = dbUrl + '/_design/' + name + '/_update/'
    demand = $scope.demandList[$index]
    id = demand.id.replace('#', '%23')
    if not $scope.hasVote(demand)
      $http.put(url + 'vote/demand-' + id).then(
        (data) -> #Success
          demand.check = true
          demand.rank  = demand.rank+1
          demand.votes[login.actualUser.name] = true
        ,(err) -> #Error
          demand.check = false
      )
    else
      $http.put(url + 'cancel_vote/demand-' + id).then(
        (data) -> #Success
          demand.check = false
          demand.rank  = demand.rank-1
          delete demand.votes[login.actualUser.name]
        ,(err) -> #Error
          demand.check = true
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
    if login.isConnect()
      modalNewDemand = $modal.open({
        templateUrl: '../partials/demand/new.html'
        controller:  'NewDemandCtrl'
        resolve: {
          categories: ($q, $http, dbUrl, name) ->
            defer = $q.defer()
            defer.resolve(config[0].value)
            return defer.promise
          project: ($q) ->
            defer = $q.defer()
            defer.resolve(project)
            return defer.promise
        }
      })

      modalNewDemand.result.then( (data) ->
        data.check = true
        $scope.demandList.push(data)
        notification.addAlert('You demand is create!', 'success')
      )

    else
      notification.addAlert('You need to be connected for doing that!', 'danger')

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
