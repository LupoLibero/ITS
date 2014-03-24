angular.module('card').
controller('CardCtrl', (parent, card, card_default, comments, $scope, $modalInstance,  $q, Card, Comment, login) ->
  $scope.card = angular.extend(parent, card_default)
  $scope.card = angular.extend($scope.card, card[0])

  $scope.close = ->
    $modalInstance.dismiss()

  $scope.saveTitle = ->
    return $scope.save('title')
  $scope.saveDescription = ->
    return $scope.save('description')

  $scope.save = (field) ->
    defer = $q.defer()
    Card.update({
      update:  'update_field'
      id:      $scope.card.id
      element: field
      value:   $scope.card[field]
      lang:    $scope.card.lang
      _rev:    $scope.card._rev
    }).then(
      (data) -> #Success
        defer.resolve(data)
      ,(err) -> #Success
        defer.reject(err)
    )
    return defer.promise


  console.log comments
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
