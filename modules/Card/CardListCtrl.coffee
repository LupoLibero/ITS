angular.module('card').
controller('CardListCtrl', ($scope, $route, cardUtils, config, $modal, login, Card, longPolling, url) ->
  $scope.login       = login
  $scope.project     = $route.current.locals.project
  $scope.default     = cardUtils.makeObject($route.current.locals.cards_default)
  $scope.translation = cardUtils.toObject($route.current.locals.cards)

  $scope.orderByRank = () ->
    (doc) ->
      -1*$scope.default.rank[doc.id]

  # Translate
  $scope.currentLang = window.navigator.language
  $scope.langs       = $scope.default.langs
  $scope.allLangs    = config[1].value
  $scope.nbCard      = $scope.default.cards.length
  # If the user change of lang
  $scope.$on('LangBarChangeLanguage', ($event, lang) ->
    Card.all({
      startkey: [$scope.project.id, lang]
      endkey:   [$scope.project.id, lang, {}]
      reduce: false
    }).then(
      (data) -> #Success
        $scope.translation = cardUtils.toObject(data)
    )
  )
  # If the user translate something
  $scope.save = (id, field, text, rev) ->
    _rev = null
    for card in $scope.default.cards
      if card.id == id
        _rev = card._rev
        break

    Card.update({
      update: 'update_field'

      id:      id
      _rev:    _rev
      from:    rev
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

    $scope.loading = true
    Card.view({
      view: 'ids'
      key:  $scope.project.id
    }).then(
      (data) -> #Success
        if data.length == 0
          count = 1
        else
          count = data[0].max + 1

        id = $scope.project.id+'.'+count
        # Create Demand
        Card.update({
          update: 'create'

          id:          id
          project_id:  $scope.project.id
          title:       $scope.newcard.title
          lang:        window.navigator.language
        }).then(
          (data) -> #Success
            data.list_id = "ideas"
            data.num     = count
            data._id     = "#{data.project_id}.#{data.id}"

            $scope.default.cards.push(data)
            $scope.nbCard = $scope.default.cards.length

            $scope.showAddCard   = false
            $scope.loading       = false
            $scope.newcard.title = ''
          ,(err) -> #Error
            $scope.loading      = false
        )
    )


  longPolling.start('cards')
  $scope.$on('ChangesOnCards', ($event, _id)->
    type      = _id.split(':')[0]
    id        = _id.split(':')[-1..-1][0].split('-')[0]
    projectId = id.split('.')[0]

    card = null
    for piece in $scope.default.cards
      if piece.id == id
        card = piece
        break

    if card?
      lang = (if type != 'card' then 'default' else card.lang)
    else
      lang = 'default'

    Card.get({
      view:        'all'
      key:         [projectId, lang, id]
      group_level: 3
    }).then(
      (data) -> #Success
    )
  )


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
            for card in $scope.default.cards
              if card.id == "#{project_id}.#{card_num}"
                defer.resolve(card)
                found = true
            if not found then defer.reject()
            return defer.promise
          card_default: (Card, $route) ->
            card_num   = $route.current.params.card_num
            project_id = $route.current.params.project_id
            return Card.view({
              view: 'get'
              startkey: ["#{project_id}.#{card_num}", 'default']
              endkey:   ["#{project_id}.#{card_num}", 'default', {}]
            })
          card: (Card, $route) ->
            card_num   = $route.current.params.card_num
            project_id = $route.current.params.project_id
            return Card.view({
              view: 'get'
              startkey: ["#{project_id}.#{card_num}", window.navigator.language]
              endkey:   ["#{project_id}.#{card_num}", window.navigator.language, {}]
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
