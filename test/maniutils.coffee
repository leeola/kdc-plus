#
# # Maniutils Tests
#
should      = require 'should'




describe 'load()', ->
  it 'should fail with no appPath'
  it 'should load manifest for the appPath'
  it 'should return validate lists when validate:true is defined'

describe 'validate()', ->
  validate = null
  before -> {validate} = require '../lib/maniutils'

  it 'should return nothing with a valid manifest', (done) ->
    manifest =
      name: 'appname'
      path: 'apppath'
      source: blocks: app: files: []

    validate manifest, (err, failures, warnings) ->
      should.not.exist err
      should.not.exist failures
      should.not.exist warnings
      done()

  it 'should callback with validation warnings properly', (done) ->
    manifest =
      source: blocks: app: files: []

    validate manifest, (err, failures, warnings) ->
      should.not.exist err
      should.not.exist failures
      warnings.length.should.equal 2
      warnings[0].should.include 'Name'
      warnings[1].should.include 'Path'
      done()


  it 'should callback with validation failures properly', (done) ->
    manifest =
      name: 'appname'
      path: 'apppath'

    validate manifest, (err, failures, warnings) ->
      should.not.exist err
      should.not.exist warnings
      failures.length.should.equal 1
      failures[0].should.include 'defined'
      done()

