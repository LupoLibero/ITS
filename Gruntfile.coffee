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
    }
    # Coffee
    coffee: {
      options:
        join: true
        bare: true
      dist: {
        files:
          'static/js/main.js': [
            'coffee/main.coffee'
            'coffee/{,*/}*.coffee'
            'coffee/{,*/}*Ctrl.coffee'
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
      e2e:{
      }
    }
  }

  grunt.registerTask('default', [
    'watch'
  ])
