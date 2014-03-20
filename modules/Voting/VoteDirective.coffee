angular.module('vote').
directive('vote', ($rootScope, login, Vote)->
  return {
    restrict: 'E'
    scope: {
      id:    '='
      hasVote: '=check'
    }
    template: '<span>'+
                '<button popover="{{ messageTooltip }}" popover-trigger="mouseenter"'+
                      ' ng-click="vote()" ng-hide="loading" ng-class="{active: check}" class="btn btn-default">+1</button>'+
                '<span us-spinner="{radius:6,width:4,length:6,lines:10}" ng-show="loading"></span>'+
              '</span>'
    link:  (scope, element, attrs) ->
      scope.check   = angular.copy(scope.hasVote)
      scope.loading = false

      scope.vote = ->
        if not scope.check and login.isConnect()
          scope.loading = true
          Vote.update({
            update:    'create'
            object_id: scope.id
          }).then(
            (data) -> #Success
              scope.loading = false
              scope.check   = !scope.check
            ,(err) -> #Error
              scope.loading = false
          )
        else if scope.check and login.isConnect()
          scope.loading = true
          Vote.update({
            update: 'delete'
            _id:    "vote--#{scope.id}--#{login.getName()}"
          }).then(
            (data) -> #Success
              scope.loading = false
              scope.check   = !scope.check
            ,(err) -> #Error
              scope.loading = false
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
