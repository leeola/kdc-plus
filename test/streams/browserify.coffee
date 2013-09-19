# 
# # Browserify Stream Tests
#
path      = require 'path'
should    = require 'should'



stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'


describe 'Browserify()', ->
  Browserify  = null
  before -> {Browserify} = require '../../lib/streams/browserify'


  describe 'with JavaScript files', ->
    stub        = path.join stubsdir, 'commonjs', 'main.js'
    it 'should load the given file with required output', (done) ->
      d = ''
      s = new Browserify stub
      s.pipe require('fs').createWriteStream 'build/foo'
      s.on 'data', (chunk) -> d += chunk
      s.on 'end', ->
        s.should.equal expected
        return done()
      expected = """
      """
