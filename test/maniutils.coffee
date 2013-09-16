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

  it 'should callback with validation warnings properly'
  it 'should callback with validation failures properly'

