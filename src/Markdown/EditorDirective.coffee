angular.module('markdown').
directive('editor', ($filter)->
  return {
    restrict: 'E'
    scope: {
      ngModel: '='
    }
    template: """
              <div>
                <textarea ng-show="editMode || fsMode"  ng-model="ngModel" ng-change="change()"            ></textarea>
                <span     ng-hide="!editMode || fsMode" bind-html-unsafe="markdown"                        ></span>

                <button ng-click="preview()"    class="glyphicon glyphicon-eye-open"     ng-show="editMode"></button>
                <button ng-click="edit()"       class="glyphicon glyphicon-pencil"       ng-hide="editMode"></button>
                <button ng-click="minify()"     class="glyphicon glyphicon-resize-small" ng-show="fsMode"  ></button>
                <button ng-click="fullscreen()" class="glyphicon glyphicon-fullscreen"   ng-hide="fsMode"  ></button>
                <button ng-click="save()"       class="glyphicon glyphicon-ok"                             ></button>
                <button ng-click="cancel()"     class="glyphicon glyphicon-remove"                         ></button>
              </div>
              """
    link: (scope, element, attrs) ->
      scope.editMode = true
      scope.fsMode   = false

      scope.change = ->
        scope.markdown = $filter('markdown')(scope.ngModel)

      scope.preview = ->
        scope.editMode = false

      scope.edit = ->
        scope.editMode = true

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
