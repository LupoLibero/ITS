angular.module('translation').
config( ($translateProvider)->
  $translateProvider.useLoader('translation')
)
