ng.directive('langBar', () ->
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
                '<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">[+]</button>'+
                '<ul class="dropdown-menu">'+
                  '<li ng-repeat="(key, value) in allLangs">'+
                    '<a ng-click="addLangue(key)"><img src="img/country-flags-png/{{key}}.png"/> {{value}}</a>'+
                  '</li>'+
                  '<li ng-if="noOtherLangs()">No other language is available</li>'+
                '</ul>'+
              '</div>'
    link: (scope, element, attrs) ->
      scope.langs[scope.lang] = true

      for key of scope.langs
        delete scope.allLangs[key]

      # If no other language available
      scope.noOtherLangs = ->
        return Object.keys(scope.allLangs).length == 0

      # Change between available language
      scope.changeLangue = (key) ->
        scope.lang = key

      # Add a new language
      scope.addLangue = (key) ->
        scope.lang = key
        scope.langs[key] = true
        delete scope.allLangs[key]
  }
)
