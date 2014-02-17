ng.directive('actualLink', ($location)->
  return {
    link: (scope, element, attrs)->
      scope.$on('$locationChangeStart', ()->
        href = element.find('a').attr('href')
        # Remove the hash because angular return without it
        href = href.replace('#', '')
        path = $location.path()

        if href == path
          element.addClass('active')
      )
  }
)
