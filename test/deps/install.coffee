# 
# # Install Deps Tests
#
fs         = require 'fs'
path       = require 'path'
should     = require 'should'




stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'



describe 'installNodeDev()', ->
  installNodeDev  = null
  before -> {installNodeDev} = require '../../lib/deps/install'

  describe 'on stubs/nodeps', ->
    stub = path.join stubsdir, 'nodeps'

    it 'should not install anything', (done) ->
      installNodeDev stub, (err) ->
        should.exist err
        err.message.should.match /not found/
        done()

  describe 'on stubs/devdeps', ->
    stub = path.join stubsdir, 'devdeps'

    it 'should install the dev deps', (done) ->
      installNodeDev stub, (err) ->
        should.not.exist err
        fs.readdir path.join(stub, 'node_modules'), (err, files) ->
          should.not.exist err
          console.log 'Holy shit files', files
          files.should.have.length 1
          done()

  describe 'on stubs/proddeps', ->
    stub = path.join stubsdir, 'proddeps'

    it 'should install the prod deps', (done) ->
      installNodeDev stub, (err) ->
        should.not.exist err
        fs.readdir path.join(stub, 'node_modules'), (err, files) ->
          should.not.exist err
          console.log 'Holy shit files', files
          files.should.have.length 1
          done()


describe 'installNodeProd()', ->
  installNodeProd  = null
  before -> {installNodeProd} = require '../../lib/deps/install'

  describe 'on stubs/nodeps', ->
    it 'should return an error'

  describe 'on stubs/devdeps', ->
    it 'should install nothing'

  describe 'on stubs/installdeps', ->
    it 'should install the deps'
