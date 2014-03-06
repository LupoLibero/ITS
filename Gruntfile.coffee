module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig {
    # Watcher
    watch: {
      all: {
        files: ['{,*/}*']
        tasks: [
          'shell:kansoPush'
        ]
      }
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
        configFile: "./test/karma.conf.js"
      unit: {
        autoWatch: true
      }
    }
    protractor:{
      options:
        configFile: "./test/protractor.conf.js"
        keepAlive:  true
        args:
          seleniumServerJar: './node_modules/protractor/selenium/selenium-server-standalone-2.39.0.jar'
          baseUrl: 'http://127.0.0.1:5984/lupolibero'
      e2e:{
      }
    }
  }

  grunt.registerTask('default', [
    'watch'
  ])
