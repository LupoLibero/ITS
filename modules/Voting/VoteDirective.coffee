angular.module('vote').
directive('vote', ($rootScope, login, Vote)->
  return {
    restrict: 'E'
    scope: {
      id:    '='
      check: '&'
    }
    template: '<button popover="{{ messageTooltip }}" popover-trigger="mouseenter" ng-click="vote()" ng-class="{active: check}" class="btn btn-default">+1</button>'
    link:  (scope, element, attrs) ->
      scope.vote = ->
        if not scope.check
          Vote.update({
            update:    'create'
            object_id: scope.id
          }).then(
            (data) -> #Success
              scope.check = !scope.check
          )
        else
          Vote.update({
            update: 'delete'
            _id:    "vote-#{login.getName()}+#{scope.id}"
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
