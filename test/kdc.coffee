# 
# # KDC Tests
#
# A few basic tests for KDC to ensure we don't accidentally change behavior.
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
    stub_path = path.join __dirname, 'stubs', 'nodeps'

    it 'should compile without failing', (done) ->
      execFile 'node', [kdc_path, stub_path], (err, stdout, stderr) ->
        # We're ignoring the Unicode LF
        stdout[...-1].should.equal 'Application has been compiled!'
        should.not.exist err
        stderr.should.equal ''
        done()


    target_md5 = '454cc66b047072d008b36ef28f22a69d'
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




