angular.module('card').
controller('CardCtrl', (card, socket, $document, $scope, $stateParams, $modalInstance,  $q, login) ->

  $scope.card = card
  $scope.card.activity = []

  socket.on('setCard', (data)->
    if data.id == $scope.card.id
      $scope.card = angular.extend($scope.card, data)
  )

  socket.emit('getActivity', card.id)
  socket.on('addActivity', (data) ->
    $scope.card.activity.unshift(data)
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
    }).then(
      (data)-> #Success
        defer.resolve()
      ,(err)-> #Error
        defer.reject()
        console.log err
    )
    return defer.promise

  $scope.keyOnNewComment = ($event) ->
    if ($event.keyCode == 13 and $event.ctrlKey) || $event.keyCode == 10
      text = $event.target.value
      $scope.addComment(text)

  $scope.addComment = (comment)->
    console.log comment
    if comment? and comment != ''
      socket.emit('newComment', {
        message:   comment
        parent_id: "card:#{$scope.card.id}"
      })
)
