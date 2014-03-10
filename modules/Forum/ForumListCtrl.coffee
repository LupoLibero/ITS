angular.module('forum').
controller('ForumListCtrl', ($scope, forums) ->
  # Put forums in the scope
  $scope.forumList = forums
)
