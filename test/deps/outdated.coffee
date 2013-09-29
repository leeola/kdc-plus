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

  describe 'on stubs/plainjs', ->
    stub = path.join stubsdir, 'plainjs'

    it 'should callback with an error', (done) ->
      outdatedNodeProd stub, (err, outdated, packages) ->
        should.exist err
        err.message.should.match /not found/
        should.not.exist outdated
        should.not.exist packages
        done()

  describe 'on stubs/nodeps', ->
    stub = path.join stubsdir, 'nodeps'

    it 'should not callback outdated', (done) ->
      outdatedNodeProd stub, (err, outdated, packages) ->
        should.exist err
        err.message.should.match /not found/
        should.not.exist outdated
        should.not.exist packages
        done()

  describe 'on stubs/devdeps', ->
    stub = path.join stubsdir, 'devdeps'

    it 'should not callback outdated', (done) ->
      outdatedNodeProd stub, (err, outdated, packages) ->
        should.not.exist err
        outdated.should.be.false
        packages.should.be.empty
        done()

  describe 'on stubs/proddeps', ->
    stub = path.join stubsdir, 'proddeps'

    it 'should callback outdated with packages', (done) ->
      outdatedNodeProd stub, (err, outdated, packages) ->
        should.not.exist err
        outdated.should.be.true
        packages.length.should.eql 1
        done()

