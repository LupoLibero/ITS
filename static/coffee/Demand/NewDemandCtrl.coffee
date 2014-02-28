ng.controller('NewDemandCtrl', ($modalInstance, $scope, $route, Demand, login) ->

  # Initialize
  project = $route.current.locals.project
  $scope.categories = $route.current.locals.config[0].value
  $scope.demand=
    title:     ''
    category:  ''

  $scope.save = ->
    if $scope.demand.title == '' or $scope.demand.category == ''
      $scope.notif.setAlert('You need to fill both fields', 'danger')
      return false

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
          created_at:  new Date().getTime()
          votes:       {}
          activity:    []
          description: ''
        })
        demand.votes[author] = true
        demand.$save().then(
          (data) -> #Success
            data.rank = 1
            $modalInstance.close(data)
        )
    )

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')
)
