angular.module('subscription').
directive('subscribe', ($rootScope, Subscription) ->
  return {
    restrict: 'E'
    scope: {
      id: '='
    }
    template: '<button class="btn btn-primary" ng-disabled="disable" ng-class="{active: value}" ng-click="click()">Subscribe</button>'
    link: (scope, element, attrs) ->
      scope.disable = true
      scope.value   = false
      scope.user    = ''

      $rootScope.$on('SignOut', ->
        scope.disable = true
        scope.value   = false
        scope.user    = ''
      )

      $rootScope.$on('SignIn', ($event, name)->
        scope.user = name
        Subscription.get({
          view: 'by_object_key'
          key:  [scope.id, name]
        }).then(
          (data) -> #Success
            scope.value = true
        )
        scope.disable = false
      )

      scope.click = ->
        if not scope.value
          Subscription.update({
            update: 'create'
            object_key: scope.id
          }).then(
            (data) -> #Success
              scope.value = !scope.value
          )
        else
          Subscription.update({
            update: 'delete'
            _id:    "subscription--#{scope.id}--#{scope.user}"
          }).then(
            (data) -> #Success
              scope.value = !scope.value
          )
  }
)
