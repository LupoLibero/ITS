angular.module('markdown').
directive('editor', ($filter)->
  return {
    restrict: 'E'
    scope: {
      ngModel: '='
      saveF:   '&save'
      rev:     '='
    }
    template: """
              <div>
                <textarea ng-show="editMode" ng-model="value"            ng-keypress="change($event)" ></textarea>
                <span     ng-hide="editMode" bind-html-unsafe="markdown" ng-dblclick="editMode=true"   ></span>

                <button ng-click="preview()"    class="glyphicon glyphicon-eye-open"     ng-show="editMode"></button>
                <button ng-click="edit()"       class="glyphicon glyphicon-pencil"       ng-hide="editMode"></button>
                <button ng-click="minify()"     class="glyphicon glyphicon-resize-small" ng-show="fsMode"  ></button>
                <button ng-click="fullscreen()" class="glyphicon glyphicon-fullscreen"   ng-hide="fsMode"  ></button>
                <button ng-click="save()"       class="glyphicon glyphicon-ok"                             ></button>
                <button ng-click="cancel()"     class="glyphicon glyphicon-remove"                         ></button>
              </div>
              """
    link: (scope, element, attrs) ->
      scope.value       = angular.copy(scope.ngModel)
      scope.markdown    = $filter('markdown')(scope.value)
      scope.editMode    = false
      scope.fsMode      = false
      scope.haveChanged = false
      scope.saverev     = null

      scope.$watch('ngModel', ->
        scope.value       = angular.copy(scope.ngModel)
        scope.markdown    = $filter('markdown')(scope.value)
      )

      scope.change = ($event)->
        if $event.keyCode == 13 && $event.ctrlKey
          scope.save()
        else if $event.keyCode == 10 && $event.ctrlKey # For ctrl+enter for Chrome
          scope.save()
        else if $event.keyCode == 27
          scope.editMode = false
        else
          scope.haveChanged = true
          scope.saverev     = angular.copy(scope.rev)
          scope.markdown    = $filter('markdown')(scope.value)

      scope.preview = ->
        scope.editMode = false

      scope.edit = ->
        scope.editMode = true

      scope.save = ->
        scope.saveF({
          value: scope.value
          rev:   scope.saverev
        }).then(
          (data)-> #Success
            scope.editMode    = false
            scope.haveChanged = false
            scope.saverev     = null
          ,(err)-> #Error
        )

      scope.cancel = ->
        scope.value    = angular.copy(scope.ngModel)
        scope.markdown = $filter('markdown')(scope.value)

      scope.fullscreen = ->
        elem = element.find('div').get(0)
        if elem.requestFullscreen
          elem.requestFullscreen()
        else if elem.msRequestFullscreen
          elem.msRequestFullscreen()
        else if elem.mozRequestFullScreen
          elem.mozRequestFullScreen()
        else if elem.webkitRequestFullscreen
          elem.webkitRequestFullscreen()

        element.find('textarea').css({
          width: '50%'
          heigh: '300px'
          float: 'left'
        })
        element.find('span').css({
          'background-color': '#fff'
          width: '50%'
          heigh: '300px'
          float: 'left'
        })


  }
)
