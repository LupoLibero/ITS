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
  }

  grunt.registerTask('default', [
    'watch'
  ])
