angular.module('forum').
controller('ForumCtrl', ($scope, forum) ->
  # put the forum in the scope
  $scope.forum = forum
)
