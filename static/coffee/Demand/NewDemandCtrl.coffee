ng.controller('NewDemandCtrl', ($modalInstance, $scope, categories, project, modalNotification, Demand, login) ->

  # Initialize
  $scope.focusSecondField   = false
  $scope.displaySecondField = false
  $scope.categories = categories
  $scope.demand=
    title:     ''
    category:  ''
  # Notification system
  $scope.notif = modalNotification

  $scope.press = ($event) ->
    if $event.keyCode == 13
      $event.preventDefault()
      $scope.displaySecondField = true
      $scope.focusSecondField   = true

  $scope.secondField = ->
    return $scope.displaySecondField

  $scope.save = ->
    if $scope.demand.title != '' and $scope.demand.category != ''
      Demand.view({
        view: 'ids'
        key:  project.id
      }).then(
        (data) -> #Success
          # If it's the first demand of the project
          if data.length == 0
            count = 1
          else
            count = data[0].max + 1
          # Get the author
          author = login.actualUser.name
          # Create Demand
          demand = new Demand({
            id:          project.id.toUpperCase() + '#' + count
            project_id:  project.id
            author:      author
            status:      "draft"
            title:       $scope.demand.title
            category:    $scope.demand.category
            created_at:  new Date().toISOString()
            rank:        1
            votes:       {}
          })
          demand.votes[author] = true
          demand.$save().then(
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
