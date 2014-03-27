angular.module('card').
controller('NewCardCtrl', ($scope, $route, Card, notification, login) ->
  # Initialize
  $scope.login = login
  project      = $route.current.locals.project
  $scope.card=
    title: ''

  $scope.addCard = ->
    $scope.showForm = true

  $scope.save = ($event) ->
    if $event.key != 'Enter'
      return false

    $scope.loading = true
    $event.preventDefault()

    if $scope.card.title == ''
      notification.setAlert('You need to fill the field', 'danger')
      return false

    Card.view({
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
        Card.update({
          update: 'create'

          id:          id
          project_id:  project.id
          title:       $scope.card.title
          lang:        window.navigator.language
        }).then(
          (data) -> #Success
            data.list_id = "ideas"

            $scope.showForm   = false
            $scope.loading    = false
            $scope.card.title = ''
            $scope.$emit('addCard', data)
          ,(err) -> #Error
            $scope.loading      = false
        )
    )
)
