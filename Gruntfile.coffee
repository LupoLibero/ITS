module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig {
    watch: {
      coffee: {
        files: ['static/coffee/*.coffee']
        tasks: [
          'coffee:dist'
          'shell:kansoPush'
        ]
      }
    }
    coffee: {
      options:
        join: true
        bare: true
      dist: {
        files:
          'static/main.js': [
            'static/coffee/main.coffee'
            'static/coffee/*.coffee'
          ]
      }
    }
    shell:{
      kansoPush:{
        options:
          stdout: true
        command: 'kanso push http://admin:admin@127.0.0.1:5984/lupolibero'
      }
    }
  }

  grunt.registerTask('default', [
    'shell:kansoPush'
    'watch'
  ])
