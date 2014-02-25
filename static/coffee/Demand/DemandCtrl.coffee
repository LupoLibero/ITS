ng.controller('DemandCtrl', ($scope, project, demand, config, Comment, login, comments, dbUrl, name, $http) ->
  $scope.project     = project
  $scope.demand      = demand
  $scope.categories  = config[0].value
  $scope.resolutions = config[1].value
  $scope.statuses    = config[2].value
  $scope.comments    = comments

  # Initialize new comment form
  $scope.newComment=
    message: ''

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

  # Create a new comment with the form
  $scope.addComment = ->
    if $scope.newComment.message != ''
      if login.isConnect()
        new Comment({
          author:      login.actualUser.name
          message:     $scope.newComment.message
          created_at:  new Date().getTime()
          parent_id:   demand._id
          votes:       {}
        }).$save().then(
          (data) -> #Success
            data.voteup   = 0
            data.votedown = 0
            $scope.comments.unshift(data)
            $scope.newComment.message = ''
          ,(err) -> #Error
            $scope.notif('Impossible to submit your comment! Please try again', 'danger')
        )

  # When click on a up vote button
  $scope.voteup = ($$index) ->
    $scope.vote($$index, 'up')

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

    url = "#{dbUrl}/_design/#{name}/_update"

    $http.put("#{url}/vote_comment_#{sens}/#{comment._id}").then(
      (data) -> #Success
        if sens == 'up'
          $scope.comments[$index].votes[login.actualUser.name] = true
          $scope.comments[$index].voteup++
        else
          $scope.comments[$index].votes[login.actualUser.name] = false
          $scope.comments[$index].votedown++
      ,(err) -> #Error
        $scope.notif.addAlert('An error has occur when trying to make you vote!', 'danger')
    )
)
