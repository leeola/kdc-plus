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
    s = new LoadStream stub_files
    s.pipe require('fs').createWriteStream 'build/foo'
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
