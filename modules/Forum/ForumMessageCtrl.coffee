angular.module('forum').
controller('ForumMessageCtrl', ($scope, $route, $location, Forum) ->
  $scope.forum     = $route.current.locals.forum

  # If a traduction is available
  if $route.current.locals.forum.length != 0
    $scope.forum = $route.current.locals.forum[0]
  else
    $scope.forum = $route.current.locals.forum_default
)
