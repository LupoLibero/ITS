ng.directive('editField', ->
  return {
    restrict: 'E'
    scope:
      ngModel: '='
      type:    '@'
      lang:    '='
      save:    '&'
    template: '<input ng-show="type == \'input\' && translation == true" type="text" ng-model="saveValue" disabled/>'+
              '<input ng-show="type == \'input\'" ng-disabled="onLoad()" ng-keyup="change()" type="text" ng-model="ngModel"/>'+
              '<textarea ng-show="type == \'textarea\' && translation == true" ng-model="saveValue" disabled></textarea>'+
              '<textarea ng-show="type == \'textarea\'" ng-disabled="onLoad()" ng-keyup="change()" ng-model="ngModel"></textarea>'+
              '<span ng-show="onLoad()" us-spinner="{width:2,length:6,radius:5}"></span>'+
              '<span ng-show="onChange()">'+
                '<button ng-click="goSave()" class="btn btn-default glyphicon glyphicon-ok"     style="color:green;"></button>'+
                '<button ng-click="cancel()" class="btn btn-default glyphicon glyphicon-remove" style="color:red;  "></button>'+
              '</span>'

    link: (scope, element, attrs) ->
      scope.haveChange = false

      scope.$on('EditFieldTranslationOn', ->
        scope.translation = true
        scope.ngModel     = ''
      )
      scope.$watch('lang', ->
        scope.saveValue = angular.copy(scope.ngModel)
        scope.translation = false
      )

      scope.change = ->
        scope.haveChange = true

      scope.goSave = ->
        scope.haveChange = false
        scope.loading = true
        scope.save().then(
          (data) -> #Success
            scope.loading = false
            scope.translation = false
            scope.saveValue = angular.copy(scope.ngModel)
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
