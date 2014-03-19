angular.module('vote').
directive('vote', ($rootScope, login, Vote)->
  return {
    restrict: 'E'
    scope: {
      id:    '='
      hasVote: '=check'
    }
    template: '<button popover="{{ messageTooltip }}" popover-trigger="mouseenter" ng-click="vote()" ng-class="{active: check}" class="btn btn-default">+1</button>'
    link:  (scope, element, attrs) ->
      scope.check = angular.copy(scope.hasVote)

      scope.vote = ->
        if not scope.check and login.isConnect()
          Vote.update({
            update:    'create'
            object_id: scope.id
          }).then(
            (data) -> #Success
              scope.check = !scope.check
          )
        else if scope.check and login.isConnect()
          Vote.update({
            update: 'delete'
            _id:    "vote--#{scope.id}--#{login.getName()}"
          }).then(
            (data) -> #Success
              scope.check = !scope.check
          )

      $rootScope.$on('SessionChanged', ->
        if login.isNotConnect()
          scope.messageTooltip = "You need to be connected"
        else if login.hasRole('sponsor')
          scope.messageTooltip = "Vote for this demand"
        else
          scope.messageTooltip = "You need to be a sponsor"
      )

  }
)
