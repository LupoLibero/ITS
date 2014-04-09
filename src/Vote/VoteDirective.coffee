angular.module('vote').
directive('vote', ($rootScope, login)->
  return {
    restrict: 'E'
    scope: {
      check:   '='
      save:    '&'
    }
    template: """
              <span>
                <button popover="{{ messageTooltip }}" popover-trigger="mouseenter"
                  ng-click="vote()" ng-hide="loading"
                  ng-class="{active: check}" class="btn btn-default">+1</button>

                <span us-spinner="{radius:6,width:4,length:6,lines:10}" ng-show="loading"></span>
              </span>
              """

    link:  (scope, element, attrs) ->
      scope.loading = false

      scope.vote = ->
        scope.loading = true
        scope.save().then(
          (data) -> #Success
            scope.loading = false
          ,(err) -> #Error
            scope.loading = false
        )

      $rootScope.$on('SessionChanged', ->
        if login.isNotConnect()
          scope.messageTooltip = "You need to be connected"
        else if login.hasRole('sponsor')
          scope.messageTooltip = "Vote for this card"
        else
          scope.messageTooltip = "You need to be a sponsor"
      )

  }
)
