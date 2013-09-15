#
# # Installer Injection Tests
#
# These are tests to ensure installer injection takes place as part of the
# compilation process.
#
# Note that this is all the "runtime depdendency" tests we do. The rest,
# that is actually making sure our runtime code installs the required deps,
# is done on the clientside during kdapp runtime. This all requires the
# KDFramework and KDViews, so we can't really test much, if any, here on
# the server.
#
{execFile}  = require 'child_process'
fs          = require 'fs'
path        = require 'path'
md5         = require 'MD5'
should      = require 'should'
verexp      = require 'verbal-expressions'




describe 'kdc()', ->
  kdc_path  = path.join __dirname, '..', 'bin', 'kdc.js'


  describe 'a simple project', ->
    stub_path = path.join __dirname, 'stubs', 'installerdeps'

    it 'should compile without failing', (done) ->
      execFile 'node', [kdc_path, stub_path], (err, stdout, stderr) ->
        # We're ignoring the Unicode LF
        stdout[...-1].should.equal 'Application has been compiled!'
        should.not.exist err
        stderr.should.equal ''
        done()


    target_md5 = 'foo'
    it "should compile and match md5 #{target_md5}", ->
      index = fs.readFileSync path.join(stub_path, 'index.js'),
        encoding: 'utf-8'
      
      # Remove some of the dynamic bits that will cause the md5 to fail.
      index = verexp()
        .beginCapture()
        .find('Compiled by kdc on ')
        .endCapture()
        .anythingBut('*/')
        .replace(index, '$1')

      index = verexp()
        .beginCapture()
        .find('BLOCK STARTS: ')
        .endCapture()
        .anything()
        .then('*/')
        .replace(index, '$1*/')

      md5(index).should.equal target_md5




