ng.controller('NewTicketCtrl', ($modalInstance, $scope, categories, project, modalNotification, Ticket, login) ->

  # Initialize
  $scope.secondField = false
  $scope.categories = categories
  $scope.ticket=
    title:     ''
    category:  ''
  # Notification system
  $scope.notif = modalNotification

  $scope.press = ($event) ->
    if $event.keyCode == 13
      $event.preventDefault()
      $scope.secondField = true

  $scope.showCategory = ->
    return $scope.secondField

  $scope.save = ->
    if $scope.ticket.title != '' and $scope.ticket.category != ''
      Ticket.view({
        view: 'ids'
        key:  project.id
      }).then(
        (data) -> #Success
          # If it's the first ticket of the project
          if data.length == 0
            count = 1
          else
            count = data[0].max + 1
          # Get the author
          author = login.actualUser.name
          # Create Ticket
          ticket = new Ticket({
            id:          project.id.toUpperCase() + '#' + count
            project_id:  project.id
            author:      author
            status:      "draft"
            title:       $scope.ticket.title
            category:    $scope.ticket.category
            created_at:  new Date().toISOString()
            votes:       {}
          })
          ticket.votes[author] = true
          ticket.$save().then(
            (data) -> #Success
              $modalInstance.close(data)
            ,(err) -> #Error
              $scope.notif.setAlert('Error while saving please try again', 'danger')
          )
      )
    else
      $scope.notif.setAlert('You need to fill both fields', 'danger')

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')
)
