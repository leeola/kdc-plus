# 
# # Commonjs Stream Tests
#
path      = require 'path'
should    = require 'should'



stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'


describe 'Commonjs()', ->
  commonjs  = null
  Commonjs  = null
  before ->
    commonjs    = require '../../lib/streams/commonjs'
    {Commonjs}  = commonjs


  describe 'with JavaScript files', ->
    stub        = path.join stubsdir, 'commonjs', 'main.js'

    it 'should load the given file with required output', (done) ->
      d = ''
      s = new Commonjs stub
      s.on 'data', (chunk) -> d += chunk
      s.on 'end', ->
        # The first line is a huge singleline require statement, so lets cut
        # that off for our sanity.
        d = d.split('\n')[1...].join('\n')

        d.should.equal expected
        return done()
      expected = """
      var required = require('./required')
      required.notify()

      },{"./required":2}],2:[function(require,module,exports){
      exports.notify = function() {
        new KDNotificationView({title: 'stub'})
      }

      },{}]},{},[1])
      ;"""


  describe 'with CoffeeScript Transforms', ->
    stub            = path.join stubsdir, 'commoncoffee', 'main.coffee'
    coffeeifyTransform  = null
    before -> {coffeeifyTransform} = commonjs

    it 'should load the given file with required output', (done) ->
      d = ''
      s = new Commonjs stub,
        transforms: [coffeeifyTransform]
        extensions: ['.coffee']
      s.on 'data', (chunk) -> d += chunk
      s.on 'end', ->
        # The first line is a huge singleline require statement, so lets cut
        # that off for our sanity.
        d = d.split('\n')[1...].join('\n')

        d.should.equal expected
        return done()
      expected = """
      // Generated by CoffeeScript 1.6.3
      (function() {
        var required;

        required = require('./required');

        required.notify();

      }).call(this);

      },{"./required":2}],2:[function(require,module,exports){
      // Generated by CoffeeScript 1.6.3
      (function() {
        exports.notify = function() {
          return new KDNotificationView({
            title: 'stub'
          });
        };

      }).call(this);

      },{}]},{},[1])
      ;"""
