angular.module('card').
controller('CardCtrl', (card, cards, socket, $document, $scope, $stateParams, $modalInstance,  $q, login) ->

  id = "#{$stateParams.project_id}.#{$stateParams.card_num}"
  if card != undefined
    $scope.card = card
    $scope.card.activity = []
    socket.emit('getDescription', card.id)
  else
    $scope.card = {}
    socket.emit('getCard', id)

  socket.on('card', (data)->
    $scope.card = data
  )

  socket.on('setCard', (data)->
    if data.id == id
      $scope.card = angular.extend($scope.card, data)
  )

  socket.emit('getActivity', id)
  socket.on('addActivity', (data) ->
    if data._id == "card:#{$scope.card.id}"
      found = false
      for activity, i in $scope.card.activity
        if activity.date == data.date
          found = true
          $scope.card.activity[i] = data
          break

      if not found
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

  $scope.subscribe = (id, check)->
    return socket.emit('setSubscription', {
      id:    id
      check: check
    })

  $scope.addComment = (comment)->
    console.log comment
    if comment? and comment != ''
      socket.emit('newComment', {
        message:   comment
        parent_id: "card:#{$scope.card.id}"
      })
)
