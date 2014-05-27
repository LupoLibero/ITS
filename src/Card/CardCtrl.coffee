angular.module('card').
controller('CardCtrl', (card, socket, $document, $scope, $stateParams, $modalInstance,  $q, login) ->

  $scope.card = {}
  card_id     = "#{$stateParams.project_id}.#{$stateParams.card_num}"

  socket.emit('setShow', card_id)
  # TODO: find something else
  # socket.on('connect', ->
  #   socket.emit('setShow', card_id)
  #   socket.emit('getDescription', card_id)
  #   socket.emit('getActivity', card_id)
  # )

  $scope.card.activity = []

  if card != undefined
    angular.extend($scope.card, card)

  socket.emit('getDescription', card_id)

  socket.on('setCard', (data)->
    if data.id == card_id
      angular.extend($scope.card, data)
  )

  socket.emit('getActivity', card_id)
  socket.on('addActivity', (data) ->
    id = data.parent_id ? data._id
    if data.parent_id ? data._id == "card:#{$scope.card.id}"
      found = false
      for activity in $scope.card.activity
        activity_date = activity.date ? activity.create_at
        data_date     = data.date     ? data.created_at
        if activity_date == data_date
          found = true
          break

      if not found
        $scope.card.activity.unshift(data)
  )

  $scope.$on('$stateChangeSuccess', ($event, to)->
    console.log to
    if to.name != 'card.show'
      $scope.close()
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

  $scope.subscribe = (_id, check)->
    return socket.emit('setSubscription', {
      _id:    _id
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
