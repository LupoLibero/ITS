ng.controller('CommentCtrl', ($scope, $route, Comment, login) ->

  # Get the comments for the resolve
  $scope.comments = $route.current.locals.comments

  # For each comment count the number of voteup and down
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

  # Initialize new comment form
  $scope.newComment=
    message: ''

  # Create a new comment with the form
  $scope.addComment = ->
    if $scope.newComment.message != ''
      if login.isConnect()
        new Comment({
          author:      login.actualUser.name
          message:     $scope.newComment.message
          created_at:  new Date().getTime()
          parent_id:   $route.current.locals.demand._id
          votes:       {}
        }).$save().then(
          (data) -> #Success
            data.voteup   = 0
            data.votedown = 0
            $scope.comments.unshift(data)
            $scope.newComment.message = ''
        )

  # When click on a up vote button
  $scope.voteup = ($index) ->
    $scope.vote($index, 'up')

  # When click on a up vote button
  $scope.votedown = ($index) ->
    $scope.vote($index, 'down')

  $scope.vote = ($index, sens) ->
    comment = $scope.comments[$index] # Get the comment

    if login.isNotConnect()
      $scope.notif.addAlert('You need to be connect!', 'danger')
      return false

    if comment.votes.hasOwnProperty(login.actualUser.name)
      $scope.notif.addAlert('You have already vote for this comment', 'danger')
      return false

    if comment.author == login.actualUser.name
      $scope.notif.addAlert('You can vote you own comment', 'danger')
      return false

    Comment.update({
      update: 'vote_' + sens
      _id: comment._id
    }).then(
      (data) -> #Success
        if sens == 'up'
          $scope.comments[$index].votes[login.actualUser.name] = true
          $scope.comments[$index].voteup++
        else
          $scope.comments[$index].votes[login.actualUser.name] = false
          $scope.comments[$index].votedown++
    )
)
