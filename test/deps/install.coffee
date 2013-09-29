# 
# # Install Deps Tests
#
path       = require 'path'
fs         = require 'fs-extra'
should     = require 'should'




stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'



describe 'installNodeDev()', ->
  installNodeDev  = null
  before -> {installNodeDev} = require '../../lib/deps/install'

  describe 'on stubs/plainjs', ->
    stub = path.join stubsdir, 'plainjs'

    it 'should return an error'

  describe 'on stubs/nodeps', ->
    stub = path.join stubsdir, 'nodeps'

    it 'should not install anything', (done) ->
      installNodeDev stub, (err, installed, packages) ->
        should.exist err
        err.message.should.match /not found/
        should.not.exist installed
        should.not.exist packages
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

    it 'should return an error'

  describe 'on stubs/nodeps', ->
    stub = path.join stubsdir, 'nodeps'

    it 'should not install anything', (done) ->
      installNodeProd stub, (err, installed, packages) ->
        should.exist err
        err.message.should.match /not found/
        should.not.exist installed
        should.not.exist packages
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


