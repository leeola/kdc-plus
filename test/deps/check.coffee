# 
# # Check Deps Tests
#
path          = require 'path'
should        = require 'should'




stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'



describe 'checkDev()', ->

describe 'checkProd()', ->

describe 'checkNodeDev()', ->
  checkNodeDev  = null
  before -> {checkNodeDev} = require '../../lib/deps/check'

  describe 'on stub/nodeps', ->
    it 'should callback false', (done) ->
      checkNodeDev
        dir: path.join stubsdir, 'nodeps'
        (err, result, list) ->
          should.not.exist err
          result.should.equal false
          list.should.equal []


