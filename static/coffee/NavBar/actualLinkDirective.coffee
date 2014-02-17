ng.directive('actualLink', ($location)->
  return {
    link: (scope, element, attrs)->
      scope.$on('$locationChangeStart', ()->

        # Remove the hash because angular return without it
        href = element.find('a').attr('href')
        href = href.replace('#', '')

        path = $location.path()
        if path == ''
          path = '/'

        if href == path
          element.addClass('active')
      )
  }
)
