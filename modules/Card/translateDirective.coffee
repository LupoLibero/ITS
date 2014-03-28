angular.module('card').
directive('translated', ->
  return {
    restrict: 'E'
    scope: {
      default:    '='
      field:      '@'
      translated: '='
    }
    template: "{{ text }}"
    link: (scope, element, attrs) ->
      field      = scope.field
      scope.text = scope.default[field]

      scope.$watch('translated', ->
        found = false
        for card in scope.translated
          if card.id == scope.default.id and card.hasOwnProperty(field)
            scope.text = card[field]
            found      = true
            break

        if not found
          scope.text = scope.default[field]
      )
  }
)
