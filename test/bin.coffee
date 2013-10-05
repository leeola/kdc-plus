# 
# # Bin Tests
#
# Just some general bin tests to make sure it's working. Note that the
# coverage for our bin is a bit weak, the primary coverage is done in
# the implementation tests. I just want to make sure to cover basic regression
# protection for the bin itself.
#
{execFile}  = require 'child_process'
path        = require 'path'
should      = require 'should'




# Our binGen is a wrapper function around execFile which returns a function
# with the bin file as a closure. Just a little utility function for our tests.
# This is sort of itense i suppose, but it makes the test cleaner dag'nabit
binGen = (binName, _args=[], _opts={}) ->
  if not (_args instanceof Array) then [_opts, _args] = [_args, []]
  _opts.addBinPath       ?= true
  _opts.autoExtension    ?= true
  _opts.includeBinExec   ?= true

  # Add the extension of this file to the binName, if binName is missing an
  # extension.
  if _opts.autoExtension and path.extname(binName) is ''
    binName += path.extname __filename
  
  # If our bin is just the name, we add the proper bin path.
  if _opts.addBinPath and binName.indexOf('/') < 0
    binName = path.resolve path.join __dirname, '..', 'bin', binName

  # If our bin name needs an executable to run it (such as coffee files),
  # this will auto add that exec and shuffle the args around accordingly.
  if _opts.includeBinExec
    switch path.extname binName
      when '.coffee'
        bin = path.join(
          require.resolve 'coffee-script'
          '..', '..', '..'
          'bin', 'coffee'
        )
      else
        bin = 'node'
    _args.unshift binName
  else
    bin = binName

  (usrargs=[], opts={}, callback=->) ->
    if opts instanceof Function
      callback = opts
      opts = {}

    # Combine the usrargs with the default args
    args = _args.concat usrargs

    execFile bin, args, opts, callback



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


  describe '(install)', ->
    bin       = null
    before -> bin = binGen 'kdc-plus', ['install']


  describe '(output)', ->
    bin       = null
    before -> bin = binGen 'kdc-plus', ['output']


