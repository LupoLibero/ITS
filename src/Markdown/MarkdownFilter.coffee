angular.module('markdown').
filter('markdown', ->
  return (text) ->
    if text == undefined
      return ''
    return marked(text, {
      sanitize: true
    })
)
