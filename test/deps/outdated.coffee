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
    it 'should callback false', (done) ->
      outdatedNodeDev path.join(stubsdir, 'nodeps'),
        (err, result, list) ->
          should.not.exist err
          result.should.equal false
          list.should.have.length 0 # List should normally be > 0, see fn
                                    # docs for reference.
          done()


