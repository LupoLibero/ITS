module.exports = function(config) {
  config.set({
    basePath: '../',
    frameworks: ['jasmine'],
    files: [
      // Vendor
      'static/vendor/jquery/dist/jquery.js',
      'static/vendor/angular/angular.js',
      'static/vendor/angular-mocks/angular-mocks.js',
      'static/vendor/spin.js/spin.js',
      'static/vendor/{,*/}dist/*.js',
      'static/vendor/{,*/}*.js',
      // Script
      'static/js/main.js',
      // Test
      'src/**/test/*Spec.coffee',
    ],
    exclude: [
      'static/vendor/{,*/}gulpfile.js',
      'static/vendor/{,*/}Gruntfile.js',
      'static/vendor/{,*/}*.min.js',
      'static/vendor/{,*/}*-min.js',
      'static/vendor/{,*/}dist/*.min.js',
      'static/vendor/{,*/}dist/*-min.js',
    ],

    // test results reporter to use
    // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['dots'],
    // web server port
    port: 9876,
    // enable / disable colors in the output (reporters and logs)
    colors: true,
    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,
    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,
    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera (has to be installed with `npm install karma-opera-launcher`)
    // - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
    // - PhantomJS
    // - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
    browsers: ['PhantomJS'],
    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,
    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false
  });
};
