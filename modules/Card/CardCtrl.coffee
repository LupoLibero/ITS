angular.module('card').
controller('CardCtrl', (parent, card, card_default, comments, $scope, $modalInstance,  $q, Card, Comment, login) ->

  parent.activity = []

  for element in card_default
    if element.hasOwnProperty('activity')
      parent.activity.push(element.activity[0])
    else
      parent = angular.extend(parent, element)

  $scope.card = angular.extend(parent, card[0])

  $scope.close = ->
    $modalInstance.dismiss()

  $scope.saveTitle = (value) ->
    return $scope.save('title', value)
  $scope.saveDescription = (value) ->
    return $scope.save('description', value)

  $scope.save = (field, value) ->
    defer = $q.defer()
    Card.update({
      update:  'update_field'
      id:      $scope.card.id
      element: field
      value:   value
      lang:    $scope.card.lang
      _rev:    $scope.card._rev
    }).then(
      (data) -> #Success
        defer.resolve(data)
      ,(err) -> #Success
        defer.reject(err)
    )
    return defer.promise

  $scope.comments = comments

  $scope.newComment=
    message: ''
    parent_id: ''

  $scope.addComment = ->
    if $scope.newComment.message != ''
      $scope.loading = true
      Comment.update({
        update: 'create'

        message:     $scope.newComment.message
        parent_id:   $scope.card._id
      }).then(
        (data) -> #Success
          data.author   = login.getName()
          data.message  = $scope.newComment.message
          $scope.comments.unshift(data)
          $scope.newComment.message = ''
          $scope.loading = false
        ,(err) -> #Error
          $scope.loading = false
      )
)
