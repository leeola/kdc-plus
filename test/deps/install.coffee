# 
# # Install Deps Tests
#
path      = require 'path'
fs        = require 'fs-extra'
rewire    = require 'rewire'
should    = require 'should'




stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'


describe 'installDev()', ->
  install     = null
  installDev  = null
  opts        = null
  before ->
    install       = rewire '../../lib/deps/install'
    {installDev}  = install
    opts =
      node  : true
      #For the future
      #bower : true
      #pip   : true
      #gem   : true

  describe 'with no package file', ->
    before ->
      install.__set__ 'installNodeDev', (ipath, opts, callback) ->
        callback (new Error 'not found'), false, []

    it 'should bail with an error', ->
      installDev 'fake', opts, (err, packages) ->
        should.exist err
        err.message.should.match /not found/
        packages.length.should.equal 0

    # Commented out until multiple installers are added
    #it 'should not call installers after the failure'

  describe 'with no dependencies', ->
    before ->
      install.__set__ 'installNodeDev', (ipath, opts, callback) ->
        callback null, true, []

    it 'should show installed with no packages', ->
      installDev 'fake', opts, (err, packages) ->
        should.not.exist err
        packages.length.should.equal 0

  describe 'on success', ->
    before ->
      install.__set__ 'installNodeDev', (ipath, opts, callback) ->
        callback null, true, ['some@dep']

    it 'should show installed with all packages concated together', ->
      installDev 'fake', opts, (err, packages) ->
        should.not.exist err
        packages.length.should.equal 1



describe 'installNodeDev()', ->
  installNodeDev  = null
  before -> {installNodeDev} = require '../../lib/deps/install'

  describe 'on stubs/plainjs', ->
    stub = path.join stubsdir, 'plainjs'

    it 'should return an error', (done) ->
      installNodeDev stub, (err, installed, packages) ->
        should.exist err
        err.message.should.match /not found/
        should.not.exist installed
        should.not.exist packages
        done()

  describe 'on stubs/nodeps', ->
    stub = path.join stubsdir, 'nodeps'

    it 'should not install anything', (done) ->
      installNodeDev stub, (err, installed, packages) ->
        should.not.exist err
        installed.should.be.false
        packages.length.should.equal 0
        done()

  describe 'on stubs/devdeps', ->
    stub = path.join stubsdir, 'devdeps'
    after (done) -> fs.remove path.join(stub, 'node_modules'), (err) ->
      if err? then throw err
      done()

    it 'should install the dev deps', (done) ->
      installNodeDev stub, (err, installed, packages) ->
        should.not.exist err
        installed.should.be.true
        packages.length.should.equal 1
        fs.readdir path.join(stub, 'node_modules'), (err, files) ->
          should.not.exist err,
            'reading node_modules returned an error'
          files.should.includeEql 'example',
            'the `example` package was not installed'
          done()

  describe 'on stubs/proddeps', ->
    stub = path.join stubsdir, 'proddeps'
    after (done) -> fs.remove path.join(stub, 'node_modules'), (err) ->
      if err? then throw err
      done()

    it 'should install the production deps', (done) ->
      installNodeDev stub, (err, installed, packages) ->
        should.not.exist err
        installed.should.be.true
        packages.length.should.equal 1
        fs.readdir path.join(stub, 'node_modules'), (err, files) ->
          should.not.exist err,
            'reading node_modules returned an error'
          files.should.includeEql 'example',
            'the `example` package was not installed'
          done()


describe 'installNodeProd()', ->
  installNodeProd  = null
  before -> {installNodeProd} = require '../../lib/deps/install'

  describe 'on stubs/plainjs', ->
    stub = path.join stubsdir, 'plainjs'

    it 'should return an error', (done) ->
      installNodeProd stub, (err, installed, packages) ->
        should.exist err
        err.message.should.match /not found/
        should.not.exist installed
        should.not.exist packages
        done()

  describe 'on stubs/nodeps', ->
    stub = path.join stubsdir, 'nodeps'

    it 'should not install anything', (done) ->
      installNodeProd stub, (err, installed, packages) ->
        should.not.exist err
        installed.should.be.false
        packages.length.should.eql 0
        done()

  describe 'on stubs/devdeps', ->
    stub = path.join stubsdir, 'devdeps'

    it 'should not install anything', (done) ->
      installNodeProd stub, (err, installed, packages) ->
        should.not.exist err
        packages.should.be.empty
        installed.should.be.false
        done()

  describe 'on stubs/proddeps', ->
    stub = path.join stubsdir, 'proddeps'
    after (done) -> fs.remove path.join(stub, 'node_modules'), (err) ->
      if err? then throw err
      done()

    it 'should install the production deps', (done) ->
      installNodeProd stub, (err, installed, packages) ->
        should.not.exist err
        installed.should.be.true
        packages.length.should.equal 1
        fs.readdir path.join(stub, 'node_modules'), (err, files) ->
          should.not.exist err,
            'reading node_modules returned an error'
          files.should.includeEql 'example',
            'the `example` package was not installed`'
          done()


