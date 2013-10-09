# 
# # Check Deps Tests
#
path      = require 'path'
rewire    = require 'rewire'
should    = require 'should'




stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'



# Note that the _outdated tests are a bit lacking due to there only
# being a single package manager currently supported. We'll need
# to outdate these once more PMs come into play.
describe '_outdated()', ->
  outdated  = null
  _outdated = null
  opts      = null
  before ->
    outdated     = rewire '../../lib/deps/outdated'
    {_outdated} = outdated
    opts =
      node  : true
      #For the future
      #bower : true
      #pip   : true
      #gem   : true

  it 'should concat the packages', ->
    outdated.__set__ 'outdatedNodeDev', (ipath, opts, callback) ->
      callback null, true, ['some@package']
    callback = (err, outdated, packages) ->
      should.not.exist err
      outdated.should.equal.true
      packages.length.should.equal 1
    _outdated 'fake', opts, callback, false


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
        should.not.exist err
        packages.should.be.empty
        outdated.should.be.false
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

