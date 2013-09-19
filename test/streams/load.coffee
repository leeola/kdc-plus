# 
# # Load Stream Tests
#
path      = require 'path'
should    = require 'should'



stubsdir  = path.join process.cwd(), 'build', 'test', 'stubs'


describe 'LoadStream()', ->
  stub_files    = [
    path.join stubsdir, 'nodeps', 'main.coffee'
    path.join stubsdir, 'nodeps', 'manifest.json'
  ]
  LoadStream    = null
  before -> {LoadStream} = require '../../lib/streams/load'


  it 'should load multiple files in a single stream', (done) ->
    d = ''
    s = new LoadStream stub_files,
      compileCoffee: false
    s.on 'data', (chunk) -> d += chunk
    s.on 'end', ->
      d.should.equal expected
      return done()

    expected = """
    {
      "name": "Stub",
      "path": ".",
      "source": {
        "blocks": {
          "app": {
            "files": [
              "./main.coffee"
             ]
          }
        }
      }
    }

    # 
    # # Test Stub
    #



    do ->
      new KDNotificationView
        title: 'Stub'
    
    """


  it 'should compile coffee files', (done) ->
    d = ''
    s = new LoadStream stub_files,
      compileCoffee: true
    s.on 'data', (chunk) -> d += chunk
    s.on 'end', ->
      d.should.equal expected
      return done()

    expected = """
    {
      "name": "Stub",
      "path": ".",
      "source": {
        "blocks": {
          "app": {
            "files": [
              "./main.coffee"
             ]
          }
        }
      }
    }

    (function() {
      (function() {
        return new KDNotificationView({
          title: 'Stub'
        });
      })();

    }).call(this);
    
    """

