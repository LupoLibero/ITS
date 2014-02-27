ng.directive('actualLink', ($location)->
  return {
    link: (scope, element, attrs)->
      scope.$on('$locationChangeStart', ()->
        # Remove the hash because angular return without it
        href = element.find('a').attr('href')
        if href != undefined
          href = href.replace('#', '')

          if href == $location.path()
            element.addClass('active')
          else
            element.removeClass('active')
      )
  }
)
