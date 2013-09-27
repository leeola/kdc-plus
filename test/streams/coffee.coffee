# 
# # Coffee Stream Tests
#
path      = require 'path'
should    = require 'should'



stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'



describe 'CoffeeFile()', ->
  stub        = path.join stubsdir, 'nodeps', 'main.coffee'
  CoffeeFile  = null
  before -> {CoffeeFile} = require '../../lib/streams/coffee'

  it 'should load and compile a file', (done) ->
    d = ''
    s = new CoffeeFile stub
    s.on 'data', (chunk) -> d += chunk
    s.on 'end', ->
      d.should.match /required to pass/
      return done()


