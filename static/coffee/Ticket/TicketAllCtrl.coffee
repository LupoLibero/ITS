ng.controller('TicketAllCtrl', ($scope, tickets, $modal, login) ->
  $scope.ticketList = tickets

  $scope.newTicketPopup = ->
    if login.isConnect()
      modalNewTicket = $modal.open({
        templateUrl: '../partials/ticket/new.html'
        controller:  'NewTicketCtrl'
      })
    else
      $scope.addAlert('You need to be connected for doing that!', 'danger')
)
