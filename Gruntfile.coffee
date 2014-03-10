module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig {
    # Watcher
    watch: {
      html: {
        files: [
          './partials/{,*/}*.html'
          './modules/{,*/}*'
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
        command: 'kanso deletedb http://admin:admin@127.0.0.1:5984/lupolibero'
      }
      kansoCreate:{
        command: 'kanso createdb http://admin:admin@127.0.0.1:5984/lupolibero'
      }
      kansoInit:{
        command: 'kanso upload ./data http://admin:admin@127.0.0.1:5984/lupolibero'
      }
      kansoPush:{
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

  grunt.registerTask('init', [
    'shell:kansoDelete'
    'shell:kansoCreate'
    'shell:kansoInit'
    'shell:kanso'
  ])
  grunt.registerTask('default', [
    'watch'
  ])
