# 
# # Gruntfile
#
# Our gruntfile defines the tasks that we will use to build and test this
# project. Note that this project will most likely only define `build` and
# `test` tasks, and that they canalso be accessed via `npm build` and
# `npm test`.
# 




module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    clean:
      build: ['build']

    coffee:
      all:
        expand  : true
        cwd     : './'
        dest    : 'build'
        ext     : '.js'
        src     : [
          'index.coffee'
          'bin/**/*.coffee'
          'lib/**/*.coffee'
          'runtime/**/*.coffee'
          'test/**/*.coffee'
        ]

    copy:
      bin:
        expand  : true
        cwd     : './'
        dest    : 'build'
        src     : ['bin/**/*.js']
      stubs:
        expand  : true
        cwd     : './'
        dest    : 'build'
        src     : ['test/stubs/**/*.*']

    mochacli:
      options:
        require : ['should', 'coffee-script']
        reporter: 'nyan'
        bail    : true
      build   : ['build/test/index.js']
      source  : ['test/index.coffee']

    replace:
      main:
        options:
          variables:
            version: '<%= pkg.version %>'
          prefix: '@@'
        files: [src: 'build/bin/kdc-plus.js', dest: 'build/bin/kdc-plus.js']


  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-mocha-cli'
  grunt.loadNpmTasks 'grunt-replace'


  grunt.registerTask 'build', ['clean', 'coffee', 'copy:bin', 'replace']

  grunt.registerTask 'test', ['copy:stubs', 'mochacli:source']
  grunt.registerTask 'test:build', ['build', 'mochacli:build']

  grunt.registerTask 'prepublish', ['test:build']
  grunt.registerTask 'default', ['prepublish']

