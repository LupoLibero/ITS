ng.controller('TicketListCtrl', ($scope, tickets, project, $modal, login, notification) ->
  $scope.ticketList = tickets
  $scope.project    = project

  $scope.newTicketPopup = ->
    if login.isConnect()
      modalNewTicket = $modal.open({
        templateUrl: '../partials/ticket/new.html'
        controller:  'NewTicketCtrl'
        resolve: {
          categories: ($q, $http, dbUrl, name) ->
            defer = $q.defer()
            $http.get(dbUrl+'/_design/'+name+'/_view/config?key="categories"').then(
              (data) -> #Success
                data = data.data.rows[0].value
                defer.resolve(data)
              ,(err) -> #Error
                defer.reject(err)
            )
            return defer.promise
          project: ($q) ->
            defer = $q.defer()
            defer.resolve(project)
            return defer.promise
        }
      })

      modalNewTicket.result.then( (data) ->
        data.rank = 1
        $scope.ticketList.push(data)
        notification.addAlert('You ticket is create!', 'success')
      )

    else
      notification.addAlert('You need to be connected for doing that!', 'danger')
)
