# 
# # Load Stream Tests
#
path          = require 'path'
{PassThrough} = require 'stream'
should        = require 'should'




stubsdir    = path.join process.cwd(), 'build', 'test', 'stubs'
coffeebin   = path.resolve path.join(
  require.resolve('coffee-script'),
  '..', '..', '..',
  'bin', 'coffee'
)



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
        d.should.match /generated by coffeescript/i
        d.should.match /required to pass/
        done()

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



describe 'StdTransform()', ->
  lowerBin      = "#{coffeebin} "+ path.join __dirname,
    '..', '_utils', 'lowerbin.coffee'
  upperbin      = "#{coffeebin} "+ path.join __dirname,
    '..', '_utils', 'upperbin.coffee'
  StdTransform  = null
  before -> {StdTransform} = require '../../lib/streams/load'

  it 'should pipe data to and back from the given executable', (done) ->
    sin   = new PassThrough()
    stdt  = new StdTransform upperBin, regExp
    sout  = new PassThrough()
    sin.pipe(stdt).pipe(sout)
    sin.write 'foo'
    sout.read().should.equal 'FOO'

  describe '.Filter()', ->
    it 'should have a filter function', ->
      filter    = StdTransform.Filter upperBin
      filter().should.be.instanceOf StdTransform

    it 'should filter based on the filter regex', ->
      filter    = StdTransform.Filter upperBin, /foo/
      should.not.exist filter 'bar'
      filter().should.be.instanceOf StdTransform

    it 'should accept a string and match extensions for that string', ->
      filter    = StdTransform.Filter upperBin, 'js'
      should.not.exist filter '/some/random/file.coffee'
      should.not.exist filter '/some/random/file.badjs'
      should.not.exist filter '/some/random/file.jsbad'
      filter('/some/random/file.js').should.be.instanceOf StdTransform

