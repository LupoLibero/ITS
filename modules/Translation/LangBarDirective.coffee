angular.module('translation').
directive('langBar', ($rootScope) ->
  return {
    restrict: 'E'
    scope: {
      langs:     '='
      allLangs:  '='
      lang:      '='
    }
    template: '<button ng-repeat="(key, value) in langs" class="btn btn-default" ng-class="{active: key == lang}" ng-click="changeLangue(key)">'+
                '<img src="img/country-flags-png/{{key}}.png"/>'+
              '</button>'+
              '<div class="btn-group">'+
                '<button ng-disabled="disable" type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">[+]</button>'+
                '<ul class="dropdown-menu">'+
                  '<li ng-repeat="(key, value) in allLangs">'+
                    '<a ng-click="addLangue(key)"><img src="img/country-flags-png/{{key}}.png"/> {{value}}</a>'+
                  '</li>'+
                  '<li ng-if="noOtherLangs()">No other language is available</li>'+
                '</ul>'+
              '</div>'
    link: (scope, element, attrs) ->
      # Delete from the list all the available languages
      for key of scope.langs
        delete scope.allLangs[key]

      $rootScope.$on('SignIn', ->
        scope.disable = false
      )

      $rootScope.$on('SignOut', ->
        scope.disable = true
      )

      scope.noOtherLangs = ->
        return Object.keys(scope.allLangs).length == 0

      scope.changeLangue = (key) ->
        scope.lang = key
        $rootScope.$broadcast('ChangeLanguage', key)

      scope.addLangue = (key) ->
        scope.lang = key
        scope.langs[key] = true
        delete scope.allLangs[key]
        $rootScope.$broadcast('NewLanguage', key)
  }
)
