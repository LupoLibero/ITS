angular.module('subscription').
directive('subscribe', ($rootScope, login, Subscription) ->
  return {
    restrict: 'E'
    scope: {
      id:   '='
      save: '&'
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
          ,(err) -> #Error
            scope.value = false
        )

      if login.isConnect()
        onSignIn()
      else
        onSignOut()

      $rootScope.$on('SignIn', -> onSignIn())
      $rootScope.$on('SignOut',-> onSignOut())

      scope.click = ->
        scope.save({
          check: scope.value
          _id:    scope.id
        }).then(
          (data)-> #Success
            scope.value = !scope.value
        )
  }
)
