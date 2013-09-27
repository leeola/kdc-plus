# 
# # Load Stream Tests
#
path      = require 'path'
should    = require 'should'



stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'


describe 'LoadMulti()', ->
  stub_files    = [
    path.join stubsdir, 'commonjs', 'main.js'
    path.join stubsdir, 'commonjs', 'required.js'
  ]
  LoadMulti    = null
  before -> {LoadMulti} = require '../../lib/streams/load'


  it 'should load multiple files in a single stream', (done) ->
    d = ''
    s = new LoadMulti stub_files
    s.on 'data', (chunk) -> d += chunk
    s.on 'end', ->
      d.match(/required to pass/g).length.should.eql 2,
        'The required matches werre not all found'
      done()


  describe '#transforms()', ->
    CoffeeTransform = null
    before -> {CoffeeTransform} = require '../../lib/streams/coffee'

    it 'should pipe incoming files to the given transform', (done) ->
      d = ''
      s = new LoadMulti [path.join stubsdir, 'nodeps', 'main.coffee']
      s.transform -> new CoffeeTransform()
      s.on 'data', (chunk) -> d += chunk
      s.on 'end', ->
        #Ignore the annoying as hell "compiled by" message
        d = d.split('\n')[1...].join('\n')
        d.should.equal expected
        return done()

      expected = """
      (function() {
        (function() {
          return new KDNotificationView({
            title: 'Stub'
          });
        })();

      }).call(this);
      
      """

    it 'should pass filename and extension to the callback', (done) ->
      d = []
      s = new LoadMulti stub_files

      s.transform (file, ext) ->
        d.push [file, ext]
        return null
      s.on 'data', -> # We don't care about the data, but subscribing to it
                      # causes the stream to free-flow
      s.on 'end', ->
        d[0][0].should.equal stub_files[0]
        d[0][1].should.equal path.extname stub_files[0]
        d[1][0].should.equal stub_files[1]
        d[1][1].should.equal path.extname stub_files[1]
        return done()
