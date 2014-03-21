angular.module('demand').
controller('NewDemandCtrl', ($scope, $route, Demand, notification) ->
  # Initialize
  project      = $route.current.locals.project
  $scope.demand=
    title: ''

  $scope.addDemand = ->
    $scope.showForm = true

  $scope.save = ($event) ->
    if $event.key != 'Enter'
      return false

    $event.preventDefault()

    if $scope.demand.title == ''
      notification.setAlert('You need to fill the field', 'danger')
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

        id = project.id+'.'+count
        # Create Demand
        Demand.update({
          update: 'create'

          id:          id
          project_id:  project.id
          title:       $scope.demand.title
          lang:        window.navigator.language
        }).then(
          (data) -> #Success
            $scope.showForm     = false
            $scope.demand.title = ''
        )
    )
)
