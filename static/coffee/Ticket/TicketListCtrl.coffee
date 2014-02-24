ng.controller('TicketListCtrl', ($scope, tickets, project, $modal, login, notification, config, $http, name, dbUrl) ->
  $scope.project    = project

  # Add tickets to the scope
  $scope.ticketList = tickets

  # Vote System
  $scope.hasVote = (ticket) ->
    if ticket.votes.hasOwnProperty(login.actualUser.name)
      return true
    else
      return false

  $scope.$on('CheckVote', ->
    for ticket in $scope.ticketList
      if $scope.hasVote(ticket)
        ticket.check = true
      else
        ticket.check = false
  )

  $scope.vote = ($index) ->
    if not login.isConnect()
      notification.addAlert('You need to be connected for doing that!', 'danger')

    url = dbUrl + '/_design/' + name + '/_update/'
    ticket = $scope.ticketList[$index]
    id = ticket.id.replace('#', '%23')
    if not $scope.hasVote(ticket)
      $http.put(url + 'vote/ticket-' + id).then(
        (data) -> #Success
          ticket.check = true
          ticket.rank  = ticket.rank+1
          ticket.votes[login.actualUser.name] = true
        ,(err) -> #Error
          ticket.check = false
      )
    else
      $http.put(url + 'cancelVote/ticket-' + id).then(
        (data) -> #Success
          ticket.check = false
          ticket.rank  = ticket.rank-1
          delete ticket.votes[login.actualUser.name]
        ,(err) -> #Error
          ticket.check = true
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

  # Create a new ticket
  $scope.newTicketPopup = ->
    if login.isConnect()
      modalNewTicket = $modal.open({
        templateUrl: '../partials/ticket/new.html'
        controller:  'NewTicketCtrl'
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

      modalNewTicket.result.then( (data) ->
        data.rank = 1
        data.check = true
        $scope.ticketList.push(data)
        notification.addAlert('You ticket is create!', 'success')
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
