angular.module('vote').
directive('vote', ($rootScope, login, Vote, notification)->
  return {
    restrict: 'E'
    scope: {
      id:      '='
      check:   '='
      element: '@'
    }
    template: '<span>'+
                '<button popover="{{ messageTooltip }}" popover-trigger="mouseenter"'+
                      ' ng-click="vote()" ng-hide="loading" ng-class="{active: check}" class="btn btn-default">+1</button>'+
                '<span us-spinner="{radius:6,width:4,length:6,lines:10}" ng-show="loading"></span>'+
              '</span>'

    link:  (scope, element, attrs) ->
      scope.loading = false

      scope.vote = ->
        if login.isNotConnect()
          notification.addAlert('You need to be connected!', 'danger')
          return false

        scope.loading = true
        promise       = null
        if not scope.check
          promise = Vote.update({
            update:    'create'
            object_id: scope.id
            element:   scope.element
          })
        else
          promise = Vote.update({
            update: 'delete'
            _id:    "vote:#{scope.element}:#{scope.id}-#{login.getName()}"
          })

        promise.then(
          (data) -> #Success
            scope.loading = false
            scope.check = !scope.check
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
