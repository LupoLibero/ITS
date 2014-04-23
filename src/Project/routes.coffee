angular.module('project').
config( ($stateProvider)->
  $stateProvider
    .state('project', {
      url:         '/project'
      templateUrl: 'partials/project/list.html'
      controller:  'ProjectListCtrl'
      resolve: {
        projects_default: (Project)->
          return Project.all({
            view: 'all'
            startkey: ['default', ""]
            endkey:   ['default', {}]
          })
        projects: (Project)->
          return Project.all({
            view: 'all'
            startkey: [window.navigator.language, ""]
            endkey:   [window.navigator.language, {}]
          })
      }
    })
)
