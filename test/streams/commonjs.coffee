# 
# # Commonjs Stream Tests
#
path      = require 'path'
should    = require 'should'



stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'


describe 'Commonjs()', ->
  commonjs  = null
  Commonjs  = null
  stub      = null
  before ->
    commonjs    = require '../../lib/streams/commonjs'
    {Commonjs}  = commonjs
    stub        = path.join stubsdir, 'commonjs', 'main.js'

  it 'should load the given file with required output', (done) ->
    d = ''
    s = new Commonjs stub
    s.on 'data', (chunk) -> d += chunk
    s.on 'end', ->
      r = /required to pass/g
      d.should.match r
      d.match(r).length.should.eql 2,
        'pattern is not matching as many times as expected'
      done()


  describe 'with a CoffeeScript Transform', ->
    coffeeifyTransform  = null
    before ->
      stub                  = path.join stubsdir, 'commoncoffee', 'main.coffee'
      {coffeeifyTransform}  = commonjs

    it 'should load the given file with required output', (done) ->
      d = ''
      s = new Commonjs stub,
        extensions: ['.coffee']
      s.transform coffeeifyTransform
      s.on 'data', (chunk) -> d += chunk
      s.on 'end', ->
        r = /\/\* required to pass\*\//g
        d.should.match r,
          'pattern is not matching'
        d.match(r).length.should.eql 2,
          'pattern is not matching as many times as expected'
        done()


