#
# # Maniutils Tests
#
should      = require 'should'




describe 'load()', ->
  load = null
  before -> {load} = require '../lib/maniutils'

  it 'should fail with no appPath', ->
    load null, (err) ->
      should.exist err
      err.message.should.match /apppath.*required/i

  it 'should load a manifest for the appPath', (done) ->
    load './test/stubs/nodeps', (err, manifest) ->
      should.not.exist err
      should.exist manifest
      manifest.name.should.equal 'Stub'
      manifest.path.should.equal '.'
      manifest.source.blocks.app.files[0].should.equal './main.coffee'
      done()

  describe 'opts.validate', ->
    it 'should return validate lists', (done) ->
      opts =
        validate: true
        name: 'emptymanifest.json'
      load './test/stubs', opts, (err, mani, vfails, vwarns) ->
        should.not.exist err
        vfails.should.be.an.instanceof Array
        vwarns.should.be.an.instanceof Array
        done()


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
      warnings[0].should.match /name.*missing/i
      warnings[1].should.match /path.*missing/i
      done()


  it 'should callback with validation failures properly', (done) ->
    manifest =
      name: 'appname'
      path: 'apppath'

    validate manifest, (err, failures, warnings) ->
      should.not.exist err
      should.not.exist warnings
      failures.length.should.equal 1
      failures[0].should.match /defined/i
      done()

