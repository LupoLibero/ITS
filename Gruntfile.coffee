module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig({
    watch: {
      options:
        livereload: true
      all: {
        files: [
          './partials/{,*/}*.html'
          './src/{,*/}*'
          './lib/{,*/}*.js'
        ]
        tasks: [
          'shell:kansoPush'
        ]
      }
      bots: {
        files: [
          './bots/{,*/}*.coffee'
        ]
        tasks: [
          'coffee:bots'
        ]
      }
    }
    concat: {
      dist: {
        src: [
          'temp/*/__init__.js'
          'temp/*/config.js'
          'temp/*/routes.js'
          'temp/*/run.js'
          'temp/*/*.js'
        ]
        dest: 'static/js/main.js'
        options:
          process: (content, src) ->
            src = src.split('/') # Split on slash
            src = src[src.length-1] # Get file name
            if (src[0].toUpperCase() == src[0] or src == 'run.js' or src == 'config.js' or src == 'routes.js')
              console.log src
              return content
            else
              return ''
      }
    }
    coffee: {
      options:
        bare: true
      dist: {
        expand: true
        cwd: 'src/'
        src: '*/*.coffee'
        dest: 'temp/'
        ext: '.js'
      }
      bots: {
        expand: true
        cwd: './bots/'
        src: '{,*/}*.coffee'
        dest: 'static/bots/'
        ext: '.js'
      }
    }
    copy: {
      dist: {
        expand: true
        filter: 'isFile'
        cwd: 'src/'
        src: '*/*.js'
        dest: 'temp/'
      }
      bots: {
        expand: true
        filter: 'isFile'
        cwd: 'bots/'
        src: '*.json'
        dest: 'static/bots/'
      }
    }
    clean: {
      options:
        force: true
      dist: {
        src: [
          "temp/"
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
  })


  grunt.registerTask('default', [
    'watch'
  ])

  grunt.registerTask('compile', [
    'copy'
    'coffee'
    'concat'
    'clean'
  ])

  grunt.registerTask('init', [
    'shell:kansoDelete'
    'shell:kansoCreate'
    'shell:kansoInit'
    'shell:kansoPush'
  ])
