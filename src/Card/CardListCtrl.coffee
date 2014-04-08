angular.module('card').
controller('CardListCtrl', ($scope, $route, cardUtils, $modal, login, Card, socket, url) ->
  $scope.login       = login
  $scope.lists       = ['ideas', 'estimated', 'funded', 'todo', 'doing', 'done']
  $scope.project     = $route.current.locals.project
  $scope.cards       = []
  # Translate
  $scope.currentLang = window.navigator.language
  $scope.allLangs    = $route.current.locals.config[1].value
  $scope.langs       = {}
  $scope.nbCard      = 0

  $scope.$on('SessionChanged', ($event, name)->
    socket.emit('setUsername', name)
  )
  socket.emit('setProject', $scope.project.id)
  socket.emit('setLang', window.navigator.language)
  socket.emit('getAll', window.navigator.language)

  socket.on('addCard', (card)->
    $scope.cards.push(card)
    $scope.langs  = cardUtils.getLangs($scope.cards)
    $scope.nbCard = $scope.cards.length
  )

  # socket.on('setVote', (id)->
  #   for card, i in $scope.cards
  #     if card.id == id
  #       $scope.cards.hasVote = true
  #       $scope.cards.votes[login.getName()] = true
  #       break
  # )

  # socket.on('setRank', (data)->
  #   for card, i in $scope.cards
  #     if card.id == data.id
  #       $scope.cards.rank = data.rank
  #       break
  # )

  # If the user change of lang
  $scope.$on('LangBarChangeLanguage', ($event, lang) ->
    $scope.cards = []
    socket.emit('setLang', lang)
  )
  # If the user translate something
  $scope.save = (id, field, text, from) ->
    _rev = null
    for card in $scope.cards
      if card.id == id
        _rev = card._rev
        break

    Card.update({
      update: 'update_field'

      id:      id
      _rev:    _rev
      from:    from
      element: field
      value:   text
      lang:    $scope.currentLang
    }).then(
      (data) -> #Success
        console.log "success"
    )

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

    socket.emit('saveCard', {
      project_id:  $scope.project.id
      title:       $scope.newcard.title
      lang:        window.navigator.language
    })


  $scope.$watch($route.current.params.card_num, (card_num) ->
    if card_num != undefined
      modal = $modal.open({
        templateUrl: 'partials/card/show.html'
        controller:  'CardCtrl'
        keyboard:    false
        resolve:
          parent: ($q) ->
            defer      = $q.defer()
            card_num   = $route.current.params.card_num
            project_id = $route.current.params.project_id
            found      = false

            for card in $scope.cards
              if card.id == "#{project_id}.#{card_num}"
                defer.resolve(card)
                found = true

            defer.reject() if not found
            return defer.promise
          card_default: (Card, $route) ->
            card_num   = $route.current.params.card_num
            project_id = $route.current.params.project_id
            return Card.view({
              view: 'get'
              startkey: ['default', "#{project_id}.#{card_num}"]
              endkey:   ['default', "#{project_id}.#{card_num}"]
            })
          card: (Card, $route) ->
            card_num   = $route.current.params.card_num
            project_id = $route.current.params.project_id
            language   = window.navigator.language
            return Card.view({
              view: 'get'
              startkey: [language, "#{project_id}.#{card_num}"]
              endkey:   [language, "#{project_id}.#{card_num}"]
            })
          comments: (Comment, $route) ->
            card_num   = $route.current.params.card_num
            project_id = $route.current.params.project_id
            return Comment.all({
              startkey: ["card:#{project_id}.#{card_num}", 0]
              endkey:   ["card:#{project_id}.#{card_num}", {}]
            })
      })

      modal.result.then( (->), ->
        url.redirect('card.list', {
          project_id: $route.current.locals.project.id
        })
      )
  )

)
