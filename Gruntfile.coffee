module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig {
    # Watcher
    watch: {
      options:
        livereload: true
      html: {
        files: [
          './partials/{,*/}*.html'
          './modules/{,*/}*'
          './static/css/{,*/}*'
          './lib/{,*/}*.js'
        ]
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
            'modules/*/__init__.coffee'
            'modules/*/config.coffee'
            'modules/*/routes.coffee'
            'modules/*/*.coffee'
          ]
      }
    }
    # Kanso
    shell:{
      options:
        stdout: true
      kansoDelete:{
        command: ->
          name = grunt.option('db') || 'default'
          return "kanso deletedb #{name}"
      }
      kansoCreate:{
        command: ->
          name = grunt.option('db') || 'default'
          return "kanso createdb #{name}"
      }
      kansoInit:{
        command: ->
          name = grunt.option('db') || 'default'
          return "kanso upload ./data #{name}"
      }
      kansoPush:{
        command: ->
          name = grunt.option('db') || 'default'
          return "kanso push #{name}"
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

  grunt.registerTask('init', [
    'shell:kansoDelete'
    'shell:kansoCreate'
    'shell:kansoInit'
    'shell:kansoPush'
  ])
  grunt.registerTask('default', [
    'watch'
  ])
