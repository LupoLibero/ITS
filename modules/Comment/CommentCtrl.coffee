angular.module('comment').
controller('CommentCtrl', ($scope, $route, Comment, login) ->

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
    console.log $route.current.locals.demand[0]._id
    if $scope.newComment.message != ''
      Comment.update({
        update: 'create'

        message:     $scope.newComment.message
        parent_id:   $route.current.locals.demand[0]._id
      }).then(
        (data) -> #Success
          data.votes    = {}
          data.author   = login.actualUser.name
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