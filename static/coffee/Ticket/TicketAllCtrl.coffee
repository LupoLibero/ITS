ng.controller('TicketAllCtrl', ($scope, tickets, $modal, login) ->
  $scope.ticketList = tickets

  $scope.newTicketPopup = ->
    if login.isConnect()
      modalNewTicket = $modal({
        templateUrl: '../static/ticket/new.html'
        controller:  'NewTicketCtrl'
      })
    else
      $scope.addAlert('You need to be connected for doing that!', 'danger')
)
