# 
# # Bin Tests
#
# Just some general bin tests to make sure it's working. Note that the
# coverage for our bin is a bit weak, the primary coverage is done in
# the implementation tests. I just want to make sure to cover basic regression
# protection for the bin itself.
#
path        = require 'path'
should      = require 'should'
{binGen}    = require './_utils'




describe 'bin/kdc-plus', ->
  stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'

  describe '(no command)', ->
    bin       = null
    before -> bin = binGen 'kdc-plus', ['compile']

    it 'should log to stderr not stdout', (done) ->
      bin ['-h'], (err, stdout, stderr) ->
        # This is a crazy hack, due to the fact that Commander.js uses STDOUT
        # instead if STDERR. There is a discussion on this issue:
        # https://github.com/visionmedia/commander.js/issues/59
        [stdout, stderr] = [stderr, stdout]

        should.not.exist err
        stdout.should.equal ''
        stderr.should.match /usage.*options/i
        done()

    # This test is commented out until i can figure a good way to check
    # if a valid command was called. When i can, we also need to run
    # this type of test for each command.
    ###
    it 'should fail with unknown arguments', (done) ->
      stub = path.join stubsdir, 'nodeps'
      bin [stub, 'bad arg'], (err, stdout, stderr) ->
        should.exist err
        stdout.should.equal ''
        stderr.should.match /unknown/i
        done()
    ###

  describe '(compile)', ->
    bin       = null
    before -> bin = binGen 'kdc-plus', ['compile']

    it 'should compile a kdapp', (done) ->
      stub = path.join stubsdir, 'nodeps'
      bin [stub, '-p', '--coffee'], (err, stdout, stderr) ->
        should.not.exist err
        stdout.should.match /required to pass/
        stderr.should.match /success/i
        done()

    it 'should support plain javascript kdapps', (done) ->
      stub = path.join stubsdir, 'plainjs'
      bin [stub, '-p'], (err, stdout, stderr) ->
        should.not.exist err
        stdout.should.match /required to pass/
        stderr.should.match /success/i
        done()

    it 'should support commonjs kdapps', (done) ->
      stub = path.join stubsdir, 'commonjs'
      bin [stub, '-p', '--commonjs'], (err, stdout, stderr) ->
        should.not.exist err
        stdout_pattern = /required to pass/g
        stdout.should.match stdout_pattern
        stdout.match(stdout_pattern).length.should.eql 2,
          'stdout is not matching as many times as expected'
        stderr.should.match /success/i
        done()
  
    it 'should accept a transform bin'

    it 'should limit the transform with an extension'

    it 'should accept multiple transform bins'

    it 'should limit multiple transforms by extensions'

  describe '(install)', ->
    bin       = null
    before -> bin = binGen 'kdc-plus', ['install']


  describe '(output)', ->
    bin       = null
    before -> bin = binGen 'kdc-plus', ['output']


