angular.module('card').
controller('CardCtrl', (card, socket, $document, $scope, $modalInstance,  $q, Card, Comment, login) ->

  $scope.card = card
  $scope.card.activity = []

  socket.on('setCard' (data)->
    if data.id == $scope.card.id
      $scope.card = angular.extend($scope.card, data)
  )

  socket.emit('getActivity', card.id)
  socket.on('addActivity', (data) ->
    $scope.card.activity.push(data)
  )

  $document.bind('keypress', ($event) ->
    if $event.keyCode == 27
      target = $event.target.tagName.toLowerCase()
      unless target in ['input', 'textarea']
        $scope.close()
  )

  $scope.close = ->
    $modalInstance.dismiss()

  $scope.saveTitle = (value, rev, lang) ->
    return $scope.save('title', value, rev, lang)
  $scope.saveDescription = (value, rev, lang) ->
    return $scope.save('description', value, rev, lang)

  $scope.save = (field, value, rev, lang) ->
    defer = $q.defer()
    socket.emit('updateField', {
      id:      $scope.card.id
      element: field
      value:   value
      lang:    lang
      _rev:    rev
    })
    defer.resolve()
    return defer.promise

  $scope.keyOnNewComment = ($event) ->
    if ($event.keyCode == 13 and $event.ctrlKey) || $event.keyCode == 10
      $scope.addComment()

  $scope.addComment = ->
    console.log $scope.newComment
    if $scope.newComment? and $scope.newComment != ''
      $scope.loading = true
      Comment.update({
        update: 'create'

        message:     $scope.newComment
        parent_id:   "card:#{$scope.card.id}"
      }).then(
        (data) -> #Success
          data.author       = login.getName()
          data.message      = $scope.newComment
          $scope.newComment = ''
          $scope.loading    = false
          $scope.comments.unshift(data)
        ,(err) -> #Error
          $scope.loading = false
      )
)
