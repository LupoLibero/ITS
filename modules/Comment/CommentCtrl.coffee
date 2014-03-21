angular.module('comment').
controller('CommentCtrl', ($scope, $route, Comment, login) ->
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

  $scope.newComment=
    message: ''

  # Create a new comment with the form
  $scope.addComment = ->
    console.log $route.current.locals.card[0]._id
    if $scope.newComment.message != ''
      Comment.update({
        update: 'create'

        message:     $scope.newComment.message
        parent_id:   $route.current.locals.card[0]._id
      }).then(
        (data) -> #Success
          data.votes    = {}
          data.author   = login.getName()
          data.voteup   = 0
          data.votedown = 0
          $scope.comments.unshift(data)
          $scope.newComment.message = ''
      )

  $scope.voteup = ($index) ->
    $scope.vote($index, 'up')

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
          $scope.comments[$index].votes[login.getName()] = true
          $scope.comments[$index].voteup++
        else
          $scope.comments[$index].votes[login.getName()] = false
          $scope.comments[$index].votedown++
    )
)
