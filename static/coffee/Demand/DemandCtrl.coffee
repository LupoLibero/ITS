ng.controller('DemandCtrl', ($scope, project, demand, config, Comment, login, comments, dbUrl, name, $http) ->
  $scope.project     = project
  $scope.demand      = demand
  $scope.categories  = config[0].value
  $scope.resolutions = config[1].value
  $scope.statuses    = config[2].value
  $scope.comments    = comments

  # Comments
  $scope.newComment=
    message: ''

  angular.forEach($scope.comments, (comment)->
    voteup   = 0
    votedown = 0
    angular.forEach(comment.votes, (vote)->
      if vote
        voteup++
      else
        votedown++
    )
    comment.voteup   = voteup
    comment.votedown = votedown
  )


  $scope.addComment = ->
    if $scope.newComment.message != ''
      if login.isConnect()
        new Comment({
          author:      login.actualUser.name
          message:     $scope.newComment.message
          created_at:  new Date().toISOString()
          demand_id:   demand.id
          votes:       {}
        }).$save().then(
          (data) -> #Success
            data.voteup   = 0
            data.votedown = 0
            $scope.comments.unshift(data)
            $scope.newComment.message = ''
          ,(err) -> #Error
            console.log "error comment"
        )

  $scope.voteup = (index) ->
    $scope.vote(index, 'up')

  $scope.votedown = (index) ->
    $scope.vote(index, 'down')

  $scope.vote = (index, sens) ->
    if login.isConnect()
      comment = $scope.comments[index]
      if not comment.votes.hasOwnProperty(login.actualUser.name) or comment.user != login.actualUser.name
        url = dbUrl + '/_design/' + name + '/_update/'
        id  = comment._id
        if sens == 'up'
          $http.put(url + 'vote_comment_up/' + id).then(
            (data) -> #Success
              $scope.comments[index].votes[login.actualUser.name] = true
              $scope.comments[index].voteup++
            ,(err) -> #Error
              console.log err
          )
        else
          $http.put(url + 'vote_comment_down/' + id).then(
            (data) -> #Success
              $scope.comments[index].votes[login.actualUser.name] = false
              $scope.comments[index].votedown++
            ,(err) -> #Error
              console.log err
          )
      else
      console.log "already vote"
    else
      console.log "need to be connect"
)
