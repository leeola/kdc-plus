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
        src     : [
          'bin/**/*.js'
          'test/stubs/**/*.*'
        ]

    mochacli:
      options:
        require : ['should']
        reporter: 'nyan'
        bail    : true
      all: ['build/test/*.js']

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

  grunt.registerTask 'build', ['clean', 'coffee', 'copy', 'replace']
  grunt.registerTask 'test:nobuild', ['mochacli']
  grunt.registerTask 'test', ['build', 'test:nobuild']
  grunt.registerTask 'prepublish', ['test']
  grunt.registerTask 'default', ['prepublish']

