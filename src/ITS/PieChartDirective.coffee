angular.module('its').
directive('pieChart', ->
  return {
    restrict: 'E'
    scope: {
      value:  '='
      size:   '='
      radius: '='
    }
    link: (scope, element, attrs) ->
      total    = angular.copy(scope.value.estimate)
      payment  = scope.value.payment
      estimate = total - scope.value.payment
      # To degree
      payment  = payment*360/total
      estimate = estimate*360/total

      s = new Snap(scope.size, scope.size)
      s.appendTo(element[0])
      half   = scope.size/2
      radius = scope.radius
      x = 0 + Math.cos(Snap.rad(-90 + payment)) * radius
      y = half + Math.sin(Snap.rad(-90 + payment)) * radius

      flag = (if payment > estimate then 1 else 0)
      p = s.path("M#{half} #{half}v-#{radius} a#{radius} #{radius} 0 #{flag} 1 #{x} #{y} Z")
      p.attr({
        fill: 'green'
      })
      p.hover(
        ->
          p.attr({
            fill: 'red'
          })
        ->
          p.attr({
            fill: 'green'
          })
      )

      flag = (if flag == 1 then 0 else 1)
      e = s.path("M#{half} #{half}v-#{radius} a#{radius} #{radius} 0 #{flag} 0 #{x} #{y} Z")
      e.attr({
        fill: 'blue'
      })
      e.hover(
        ->
          e.attr({
            fill: 'red'
          })
        ->
          e.attr({
            fill: 'blue'
          })
      )

  }
)
