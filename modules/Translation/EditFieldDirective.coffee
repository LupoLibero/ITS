ng.directive('editField', ->
  return {
    restrict: 'E'
    scope:
      ngModel: '='
      type:    '@'
      lang:    '='
      save:    '&'
    template: '<input ng-show="type == \'input\'" ng-disabled="onLoad()" ng-keyup="change()" type="text" ng-model="ngModel"/>'+
              '<textarea ng-show="type == \'textarea\'" ng-disabled="onLoad()" ng-keyup="change()" ng-model="ngModel"></textarea>'+
              '<span ng-show="onLoad()" us-spinner="{width:2,length:6,radius:5}"></span>'+
              '<span ng-show="onChange()">'+
                '<button ng-click="goSave()" class="btn btn-default glyphicon glyphicon-ok"     style="color:green;"></button>'+
                '<button ng-click="cancel()" class="btn btn-default glyphicon glyphicon-remove" style="color:red;  "></button>'+
              '</span>'

    link: (scope, element, attrs) ->
      scope.haveChange = false

      scope.$watch('lang', ->
        scope.saveValue = angular.copy(scope.ngModel)
      )

      scope.change = ->
        scope.haveChange = true

      scope.goSave = ->
        scope.haveChange = false
        scope.loading = true
        scope.saveValue = angular.copy(scope.ngModel)
        scope.save().then(
          (data) -> #Success
            scope.loading = false
          ,(err) -> #Error
            scope.haveChange = true
            scope.loading = false
        )

      scope.onChange = ->
        return scope.haveChange

      scope.onLoad = ->
        return scope.loading

      scope.cancel = ->
        scope.ngModel    = scope.saveValue
        scope.haveChange = false
  }
)
