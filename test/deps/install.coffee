# 
# # Install Deps Tests
#
path          = require 'path'
should        = require 'should'




stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'



describe 'installNodeDev()', ->
  installNodeDev  = null
  before -> {installNodeDev} = require '../../lib/deps/install'

  describe 'on stubs/nodeps', ->
    it 'should return an error', (done) ->
      installNodeDev path.join(stubsdir, 'nodeps'),
        (err) ->
          should.exist err
          err.message.should.match /not found/
          done()

  describe 'on stubs/devdeps', ->
    it 'should install the dev deps', (done) ->
      installNodeDev path.join(stubsdir, 'devdeps'),
        (err) ->
          should.not.exist err
          done()

  describe 'on stubs/proddeps', ->
    it 'should install the deps', (done) ->
      installNodeDev path.join(stubsdir, 'proddeps'),
        (err) ->
          should.not.exist err
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
