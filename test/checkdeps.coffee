# 
# # Check Deps Tests
#
should        = require 'should'
{
  check
  checkNode
}             = require '../lib/checkdeps'



describe 'check()', ->


describe 'checkNodeDev()', ->
  describe 'with stub/nodeps', ->
    it 'should callback false', (done) ->
      checkNode
        devDeps : true
        prodDeps: true
        (err, result, list) ->
          should.not.exist err
          result.should.equal false
          list.should.equal []


  describe 'with stub/devdeps', ->
    it 'should callback true', ->
      checkNode
        devDeps : true
        prodDeps: true
        (err, result, list) ->
          should.not.exist err
          result.should.equal true
          # This test is a bit unique, because
          list.should.equal []



