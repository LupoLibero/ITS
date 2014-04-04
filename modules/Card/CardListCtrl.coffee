angular.module('card').
controller('CardListCtrl', ($scope, $route, cardUtils, $modal, login, Card, longPolling, url) ->
  $scope.login       = login
  $scope.project     = $route.current.locals.project
  $scope.lists       = ['ideas', 'estimated', 'funded', 'todo', 'doing', 'done']
  $scope.cards       = cardUtils.makeCards(
                        $route.current.locals.cards_default,
                        $route.current.locals.cards
                      )
  $scope.workflow    = $route.current.locals.workflow

  $scope.rank = () ->
    (doc) ->
      -1*$scope.workflow.rank[doc.id]

  # Translate
  $scope.currentLang = window.navigator.language
  $scope.langs       = cardUtils.getLangs($scope.cards)
  $scope.allLangs    = $route.current.locals.config[1].value
  $scope.nbCard      = $scope.cards.length
  # If the user change of lang
  $scope.$on('LangBarChangeLanguage', ($event, lang) ->
    Card.all({
      startkey: [lang, "#{$scope.project.id}."]
      endkey:   [lang, "#{$scope.project.id}.a"]
    }).then(
      (data) -> #Success
        $scope.translation = cardUtils.makeCards(
                              $route.current.locals.cards_default,
                              data
                            )
        $scope.$emit('ChangeLanguageSuccess')
    )
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
            data._id     = "card:#{data.id}"
            data.title   = {
              content: data.title
              _rev:    1
            }

            $scope.langs[data.lang] ? 0
            $scope.langs[data.lang] += 1

            $scope.workflow[0].cards[data.id] = {
              id:      data.id
              list_id: "ideas"
            }

            $scope.cards.push(data)
            $scope.nbCard = $scope.cards.length

            $scope.showAddCard   = false
            $scope.loading       = false
            $scope.newcard.title = ''
          ,(err) -> #Error
            $scope.loading      = false
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
