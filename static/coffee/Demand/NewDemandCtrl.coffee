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
        Demand.update({
          update: 'create'

          id:          project.id.toUpperCase() + '#' + count
          project_id:  project.id
          title:       $scope.demand.title
          category:    $scope.demand.category
          lang:        window.navigator.language
        }).then(
          (data) -> #Success
            console.log data
            data.rank   = 1
            data.status = 'draft'
            data.votes  = {}
            data.votes[login.actualUser.name] = true
            $modalInstance.close(data)
        )
    )

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')
)
