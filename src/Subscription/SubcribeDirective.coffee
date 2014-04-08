angular.module('subscription').
directive('subscribe', ($rootScope, login, Subscription) ->
  return {
    restrict: 'E'
    scope: {
      id: '='
    }
    template: '<button class="btn btn-primary" ng-disabled="disable" ng-class="{active: value}" ng-click="click()">Subscribe</button>'
    link: (scope, element, attrs) ->
      onSignOut = ->
        scope.disable = true
        scope.value   = false

      onSignIn = ->
        scope.disable = false
        Subscription.get({
          view: 'by_object_key'
          key:  [scope.id, login.getName()]
        }).then(
          (data) -> #Success
            scope.value = true
        )

      if login.isConnect()
        onSignIn()
      else
        onSignOut()

      $rootScope.$on('SignIn', -> onSignIn())
      $rootScope.$on('SignOut',-> onSignOut())

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
            _id:    "subscription:#{scope.id}-#{login.getName()}"
          }).then(
            (data) -> #Success
              scope.value = !scope.value
          )
  }
)
