# 
# # Check Deps Tests
#
path          = require 'path'
should        = require 'should'




stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'



describe 'outdatedDev()', ->

describe 'outdatedProd()', ->

describe 'outdatedNodeDev()', ->
  outdatedNodeDev  = null
  before -> {outdatedNodeDev} = require '../../lib/deps/outdated'

  describe 'on stub/nodeps', ->
    it 'should callback true', (done) ->
      outdatedNodeDev path.join(stubsdir, 'nodeps'),
        (err, result, list) ->
          should.not.exist err
          result.should.equal true
          list.should.have.length 0 # List should normally be > 0, see fn
                                    # docs for reference.
          done()

  describe 'on stub/devdeps', ->
    it 'should callback true', (done) ->
      outdatedNodeDev path.join(stubsdir, 'devdeps'),
        (err, result, list) ->
          should.not.exist err
          result.should.equal true
          list.should.have.length 0 # List should normally be > 0, see fn
                                    # docs for reference.
          done()

  describe 'on stub/installdeps', ->
    it 'should callback true', (done) ->
      outdatedNodeDev path.join(stubsdir, 'installdeps'),
        (err, result, list) ->
          should.not.exist err
          result.should.equal true
          list.should.have.length 0 # List should normally be > 0, see fn
                                    # docs for reference.
          done()

describe 'outdatedNodeProd()', ->
  outdatedNodeProd = null
  before -> {outdatedNodeProd} = require '../../lib/deps/outdated'

  describe 'on stubs/nodeps', ->
    it 'should callback false'

  describe 'on stubs/devdeps', ->
    it 'should callback false'

  describe 'on stubs/installdeps', ->
    it 'should callback false with a list of modules'

