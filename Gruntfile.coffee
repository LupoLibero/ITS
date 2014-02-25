module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig {
    # Watcher
    watch: {
      coffee: {
        files: ['static/coffee/{,*/}*.coffee']
        tasks: [
          'coffee:dist'
        ]
      }
    }
    # Coffee
    coffee: {
      options:
        join: true
        bare: true
      dist: {
        files:
          'static/js/main.js': [
            'static/coffee/main.coffee'
            'static/coffee/{,*/}*.coffee'
            'static/coffee/{,*/}*Ctrl.coffee'
          ]
      }
    }
    # Kanso
    shell:{
      kansoPush:{
        options:
          stdout: true
        command: 'kanso push http://admin:admin@127.0.0.1:5984/lupolibero'
      }
    }
    # Testing
    karma: {
      options:
        frameworks: ['jasmine']
        runnerPort: 8800
        browsers: ['Chrome']
        reporters: ['dots']
        files: [
          'static/vendor/angular/angular.min.js'
          'static/vendor/{,*/}*.min.js'
          'static/coffee/main.coffee'
          'static/coffee/{,*/}*.coffee'
          'test/unit/{,*/}*.coffee'
        ]
      unit: {
        autoWatch: true
      }
    }
    protractor:{
      options:
        args:
          seleniumServerJar: './node_modules/protractor/selenium/selenium-server-standalone-2.39.0.jar'
          chromeDriver: './node_modules/protractor/selenium/chromedriver.exe'
          chromeOnly: true
          browser: 'Chrome'
          specs: [
            'test/e2e/*.js'
          ]
      e2e:{
      }
    }
  }

  grunt.registerTask('default', [
    'watch'
  ])
