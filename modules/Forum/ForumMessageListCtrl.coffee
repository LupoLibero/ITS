angular.module('forum').
controller('ForumMessageListCtrl', ($scope, forum_messages_default, forum_messages, forum, $modal, login, config, Forum) ->

  # Add forum messages and forum to the scope
  $scope.forum    = forum
  $scope.forumMessageList = forum_messages_default
)
