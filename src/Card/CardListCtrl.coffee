angular.module('card').
controller('CardListCtrl', ($scope, $state, cardUtils, login, socket, $q, notification) ->
  $scope.login       = login
  $scope.lists       = ['ideas', 'estimated', 'funded', 'todo', 'doing', 'done']
  $scope.project     = $state.$current.locals.globals.project
  $scope.cards       = []
  # Translate
  $scope.currentLang = window.navigator.language
  $scope.allLangs    = $state.$current.locals.globals.config[1].value
  $scope.langs       = {}
  $scope.nbCard      = 0

  $scope.$on('SessionChanged', ($event, name)->
    socket.emit('setUsername', name)
    socket.emit('setPassword', login.getPassword())
    if login.isConnect()
      socket.emit('getVote')
  )

  socket.emit('getAll')
  socket.on('connect', ->
    socket.emit('setUsername', login.getName())
    socket.emit('setProject', $scope.project.id)
    socket.emit('setLang', $scope.currentLang)
    socket.emit('getAll')
  )

  socket.on('setCard', (data)->
    data = cardUtils.generateSlug(data)
    found = false
    for card, i in $scope.cards
      if card.id == data.id
        $scope.cards[i] = angular.extend(card, data)
        found = true
        break

    $scope.cards.push(data) if not found
    $scope.langs  = cardUtils.getLangs($scope.cards)
    $scope.nbCard = $scope.cards.length
  )

  $scope.hasVote = (vote) ->
    return vote == login.getName()

  $scope.saveVote = (id, check) ->
    defer = $q.defer()
    if login.isConnect()
      socket.emit('setVote', {
        id:      id
        check:   check
        element: 'card'
      }).then(
        (data)-> #Success
          defer.resolve()
        ,(err)-> #Error
          defer.reject()
      )
    else
      defer.reject()
    return defer.promise

  # If the user change of lang
  $scope.$on('LangBarChangeLanguage', ($event, lang) ->
    socket.emit('setLang', lang)
    socket.emit('getTitle')
  )
  # If the user translate something
  $scope.save = (id, field, text, from) ->
    _rev = null
    for card in $scope.cards
      if card.id == id
        _rev = card._rev
        break

    socket.emit('updateField', {
      id:      id
      _rev:    _rev
      from:    from
      element: field
      value:   text
      lang:    $scope.currentLang
    })

  $scope.showAddCard   = false
  $scope.newcard= {
    title: ''
  }

  $scope.saveNewCard = ($event) ->
    if $event.keyCode != 13
      return false

    $event.preventDefault()
    if $scope.newcard.title == ''
      notification.setAlert('You need to fill the field', 'danger')
      return false

    $scope.loading = true
    socket.emit('newCard', {
      project_id:  $scope.project.id
      title:       $scope.newcard.title
      lang:        $scope.currentLang
      author:      login.getName()
    }).then(
      (data) -> #Success
        $scope.showAddCard   = false
        $scope.loading       = false
        $scope.newcard.title = ''
      ,(err) -> #Error
        console.log err
        $scope.loading      = false
    )
)
